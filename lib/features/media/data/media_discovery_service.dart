import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/media_models.dart';

class MediaDiscoveryService {
  final GraphQLClient _aniListClient = GraphQLClient(
    link: HttpLink('https://graphql.anilist.co'),
    cache: GraphQLCache(),
  );

  String get _omdbApiKey => dotenv.get('OMDB_API_KEY', fallback: '');

  Future<List<VantageMedia>> searchMedia(String query) async {
    final results = await Future.wait([
      _searchAniList(query, 'ANIME'),
      _searchAniList(query, 'MANGA'),
      _searchOMDB(query),
      _searchGoogleBooks(query),
    ]);
    return results.expand((x) => x).toList();
  }

  Future<List<VantageMedia>> _searchAniList(String query, String type) async {
    const String searchPath = r'''
      query ($search: String, $type: MediaType) {
        Page (perPage: 5) {
          media (search: $search, type: $type) {
            id
            title { romaji english }
            coverImage { large }
            bannerImage
            description
            episodes
            chapters
            genres
            characters (perPage: 5, sort: [ROLE]) {
              nodes {
                name { full }
                image { medium }
              }
            }
          }
        }
      }
    ''';

    final result = await _aniListClient.query(QueryOptions(
      document: gql(searchPath),
      variables: {'search': query, 'type': type},
    ));

    if (result.hasException) return [];

    final List<dynamic> list = result.data?['Page']['media'] ?? [];
    return list.map((m) {
      final List<dynamic> charNodes = m['characters']?['nodes'] ?? [];
      return VantageMedia(
        id: 'al_${m['id']}',
        externalId: m['id'].toString(),
        source: 'anilist',
        title: m['title']['romaji'] ?? m['title']['english'],
        imageUrl: m['coverImage']['large'],
        bannerUrl: m['bannerImage'],
        description: m['description'],
        type: type == 'ANIME' ? MediaType.anime : MediaType.manga,
        totalUnits: type == 'ANIME' ? m['episodes'] : m['chapters'],
        currentUnit: 0,
        genres: List<String>.from(m['genres'] ?? []),
        characters: charNodes.map((c) => {
          'name': c['name']['full'],
          'imageUrl': c['image']['medium'],
        }).toList(),
      );
    }).toList();
  }

  Future<List<VantageMedia>> _searchOMDB(String query) async {
    if (_omdbApiKey.isEmpty) return [];
    
    final url = Uri.parse('https://www.omdbapi.com/?apikey=$_omdbApiKey&s=$query');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Response'] == 'False') return [];
        
        final List<dynamic> items = data['Search'] ?? [];
        return items.map((item) => VantageMedia(
          id: 'omdb_${item['imdbID']}',
          externalId: item['imdbID'],
          source: 'omdb',
          title: item['Title'],
          imageUrl: item['Poster'] != 'N/A' ? item['Poster'] : null,
          type: item['Type'] == 'series' ? MediaType.series : MediaType.movie,
          currentUnit: 0,
        )).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<VantageMedia?> fetchFullOMDBDetails(VantageMedia basicMedia) async {
    if (_omdbApiKey.isEmpty || basicMedia.externalId == null) return basicMedia;

    final url = Uri.parse('https://www.omdbapi.com/?apikey=$_omdbApiKey&i=${basicMedia.externalId}&plot=full');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Response'] == 'False') return basicMedia;

        final List<String> actorsList = (data['Actors'] as String? ?? '').split(', ');
        final List<Map<String, dynamic>> characters = actorsList.where((a) => a.isNotEmpty).map((actor) => {
          'name': actor,
          'imageUrl': null,
        }).toList();

        // Conversión segura de totalUnits
        int? totalUnits;
        if (data['totalSeasons'] != null && data['totalSeasons'] != 'N/A') {
          totalUnits = int.tryParse(data['totalSeasons'].toString());
        }

        return VantageMedia(
          id: basicMedia.id,
          externalId: basicMedia.externalId,
          source: basicMedia.source,
          title: data['Title'] ?? basicMedia.title,
          imageUrl: data['Poster'] != 'N/A' ? data['Poster'] : basicMedia.imageUrl,
          bannerUrl: data['Poster'] != 'N/A' ? data['Poster'] : null,
          description: data['Plot'],
          type: basicMedia.type,
          currentUnit: basicMedia.currentUnit,
          totalUnits: totalUnits,
          genres: (data['Genre'] as String? ?? '').split(', '),
          characters: characters,
        );
      }
    } catch (_) {}
    return basicMedia;
  }

  Future<List<VantageMedia>> _searchGoogleBooks(String query) async {
    final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=5');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) {
          final info = item['volumeInfo'];
          return VantageMedia(
            id: 'gb_${item['id']}',
            externalId: item['id'],
            source: 'google_books',
            title: info['title'],
            imageUrl: info['imageLinks']?['thumbnail'],
            bannerUrl: info['imageLinks']?['extraLarge'] ?? info['imageLinks']?['large'] ?? info['imageLinks']?['thumbnail'],
            description: info['description'],
            type: MediaType.book,
            totalUnits: info['pageCount'] is int ? info['pageCount'] : int.tryParse(info['pageCount']?.toString() ?? ''),
            currentUnit: 0,
            authors: info['authors'] != null ? List<String>.from(info['authors']) : null,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }
}
