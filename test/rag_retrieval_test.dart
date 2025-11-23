import 'package:flutter_test/flutter_test.dart';
import 'package:artificial_intelegence/repo/chat_repo.dart';

void main() {
  group('RAG Retrieval Logic', () {
    // 1. Mock Data (We don't need to load the real file for unit tests)
    final List<Map<String, dynamic>> mockKB = [
      {
        "id": "policy_test",
        "category": "Test",
        "keywords": ["sick", "ill", "doctor"],
        "answer": "Sick leave is 8 days."
      },
      {
        "id": "policy_test_2",
        "category": "Test",
        "keywords": ["remote", "wfh"],
        "answer": "Remote work is allowed."
      }
    ];

    // 2. Test Case: Keyword Match
    test('should retrieve context when keyword exists', () {
      String query = "I feel sick today";
      String result = ChatRepo.retrieveContext(query, mockKB);

      expect(result, contains("Sick leave is 8 days"));
    });

    // 3. Test Case: No Match
    test('should return default message when no keyword found', () {
      String query = "I want a burger";
      String result = ChatRepo.retrieveContext(query, mockKB);

      expect(
          result, contains("No specific company policy information was found"));
    });

    // 4. Test Case: Case Insensitivity
    test('should handle uppercase input', () {
      String query = "CAN I WORK REMOTE?";
      String result = ChatRepo.retrieveContext(query, mockKB);

      expect(result, contains("Remote work is allowed"));
    });
  });
}
