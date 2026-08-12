import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ==================== AUTH ====================
  static Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.roominventory://login-callback/',
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  // ==================== PLACES ====================
  static Future<List<dynamic>> getPlaces() async {
    final response = await _client.from('places').select().order('idplace');
    return response;
  }

  static Future<void> insertPlace(Map<String, dynamic> data) async {
    await _client.from('places').insert(data);
  }

  static Future<void> updatePlace(String id, Map<String, dynamic> data) async {
    await _client.from('places').update(data).eq('idplace', id);
  }

  static Future<void> deletePlace(String id) async {
    await _client.from('places').delete().eq('idplace', id);
  }

  // ==================== ZONES ====================
  static Future<List<dynamic>> getZones() async {
    final response = await _client
        .from('zones')
        .select('*, places(idplace, placename)')
        .order('idzone');
    return response;
  }

  static Future<void> insertZone(Map<String, dynamic> data) async {
    await _client.from('zones').insert(data);
  }

  static Future<void> deleteZone(String id) async {
    await _client.from('zones').delete().eq('idzone', id);
  }

  // ==================== ITEMS ====================
  static Future<List<dynamic>> getItems() async {
    final response = await _client.rpc('get_items_with_details');
    return response as List<dynamic>;
  }

  static Future<List<dynamic>> getItemsWithDetailsHierarchical() async {
    final response = await _client.rpc('get_items_with_details_hierarchical');
    return response as List<dynamic>;
  }

  static Future<void> insertItem(
      Map<String, dynamic> itemData, List<Map<String, dynamic>> details) async {
    await _client.from('items').insert(itemData);
    if (details.isNotEmpty) {
      await _client.from('details').insert(details);
    }
  }

  static Future<void> deleteItem(String idItem) async {
    // Primeiro elimina os detalhes associados (FK constraint)
    await _client.from('details').delete().eq('fk_iditem', idItem);

    // Elimina associações a eventos (se existirem)
    await _client.from('item_event').delete().eq('fk_iditem', idItem);

    // Só depois elimina o item
    await _client.from('items').delete().eq('iditem', idItem);
  }

  // ==================== EVENTS ====================
  static Future<List<dynamic>> getEvents() async {
    final response =
        await _client.from('events').select().order('date', ascending: false);
    print(response);
    return response;
  }

  static Future<void> insertEvent(Map<String, dynamic> data) async {
    await _client.from('events').insert(data);
  }

  static Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await _client.from('events').update(data).eq('idevent', id);
  }

  static Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('idevent', id);
  }

  static Future<Map<String, dynamic>?> getEventDetails(String eventId) async {
    final response =
        await _client.rpc('get_event_details', params: {'p_event_id': eventId});
    if (response is List && response.isNotEmpty) return response.first;
    return null;
  }

  // ==================== ITEM_EVENT ====================
  static Future<List<dynamic>> getItemEvents(String eventId) async {
    final response = await _client
        .from('item_event')
        .select(
            '*, items(iditem, itemname, zones(idzone, zonename, places(idplace, placename)))')
        .eq('fk_idevent', eventId)
        .order('idie');
    return response;
  }

  static Future<void> addItemToEvent(String eventId, String itemId) async {
    await _client.from('item_event').insert({
      'fk_idevent': eventId,
      'fk_iditem': itemId,
    });
  }

  static Future<void> removeItemFromEvent(int idIE) async {
    await _client.from('item_event').delete().eq('idie', idIE);
  }

  static Future<List<dynamic>> getItemsAvailableForEvent(String eventId) async {
    final response = await _client
        .rpc('get_items_available_for_event', params: {'p_event_id': eventId});
    return response as List<dynamic>;
  }

  // ==================== CHANNELS / DMX ====================
  static Future<List<dynamic>> getChannelsWithConnections() async {
    final response = await _client.rpc('get_channels_with_connections');
    print(response);
    return response as List<dynamic>;
  }

  static Future<bool> saveChannelsConfig(Map<String, dynamic> payload) async {
    final result = await _client.rpc('save_channels_config', params: {
      'p_states': payload['states'],
      'p_connections': payload['connections'],
    });
    return result == true;
  }

  // ==================== STATS ====================
  static Future<List<dynamic>> getEventStats() async {
    return await _client.rpc('get_event_stats') as List<dynamic>;
  }

  static Future<List<dynamic>> getPlaceStats() async {
    return await _client.rpc('get_place_stats') as List<dynamic>;
  }
}
