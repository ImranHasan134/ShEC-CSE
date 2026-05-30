import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/profile/models/profile_state.dart';

class FeedbackService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<void> submitFeedback({
    required int rating,
    required String comment,
  }) async {
    final user = _client.auth.currentUser;
    final profile = currentProfile.value;

    await _client.from('feedbacks').insert({
      'user_id': user?.id,
      'user_name': profile.name.isEmpty ? 'Anonymous' : profile.name,
      'rating': rating,
      'comment': comment,
    });
  }
}
