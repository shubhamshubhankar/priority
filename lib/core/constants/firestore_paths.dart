class FirestorePaths {
  FirestorePaths._();

  static String user(String uid) => 'users/$uid';

  static String notes(String uid) => 'users/$uid/notes';
  static String note(String uid, String noteId) => 'users/$uid/notes/$noteId';

  static String noteItems(String uid, String noteId) =>
      'users/$uid/notes/$noteId/items';
  static String noteItem(String uid, String noteId, String itemId) =>
      'users/$uid/notes/$noteId/items/$itemId';

  static String tasks(String uid) => 'users/$uid/tasks';
  static String task(String uid, String taskId) => 'users/$uid/tasks/$taskId';

  static String subtasks(String uid, String taskId) =>
      'users/$uid/tasks/$taskId/subtasks';
  static String subtask(String uid, String taskId, String subtaskId) =>
      'users/$uid/tasks/$taskId/subtasks/$subtaskId';

  static String goals(String uid) => 'users/$uid/goals';
  static String goal(String uid, String goalId) => 'users/$uid/goals/$goalId';

  static String milestones(String uid, String goalId) =>
      'users/$uid/goals/$goalId/milestones';
  static String milestone(String uid, String goalId, String milestoneId) =>
      'users/$uid/goals/$goalId/milestones/$milestoneId';
}
