abstract class MotivationalEvent {
  MotivationalEventType type;
  final bool changeTaskState = false;
  final bool changeStarState = false;
  String triggerStarType = '';
}

enum MotivationalEventType {
  allEmpty,
  notEmptyTodo,
  firstCompleted,
  secondCompleted,
  justAdded,
  keepAdding,
  startDoing,
  tutorialActive,
  lastTask,
  onlyRepeatableLeft,
  allDone,
  taskCompletedChanged,
  taskDeletedChanged,
  taskAddedChanged,
  dayStreakChanged,
  jumpChanged,
  tutorialChanged,
  photoAddedChanged,
  objectiveCompleted,
  tutorialCompleted,
}

class MotivationalEventNotEmptyTodo extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.notEmptyTodo;
  final bool changeTaskState = true;
  final bool changeStarState = false;
}

class MotivationalEventFirstCompleted extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.firstCompleted;

  final bool changeTaskState = true;
  final bool changeStarState = false;
}

class MotivationalEventSecondCompleted extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.secondCompleted;

  final bool changeTaskState = true;
  final bool changeStarState = false;
}

class MotivationalEventJustAdded extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.justAdded;

  final bool changeTaskState = true;
  final bool changeStarState = false;
}

class MotivationalEventKeepAdding extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.keepAdding;

  final bool changeTaskState = true;
  final bool changeStarState = false;
}

class MotivationalEventStartDoing extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.startDoing;

  final bool changeTaskState = true;
  final bool changeStarState = false;
}

class MotivationalEventTutorialActive extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.tutorialActive;
  final bool changeTaskState = true;
  final bool changeStarState = false;
}

class MotivationalEventLastTask extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.lastTask;

  final bool changeTaskState = true;
  final bool changeStarState = false;
}

class MotivationalEventOnlyRepeatableLeft extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.onlyRepeatableLeft;

  final bool changeTaskState = true;
  final bool changeStarState = false;
}

class MotivationalEventAllDone extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.allDone;
  final bool changeTaskState = true;
  final bool changeStarState = false;
}

class MotivationalEventAllEmpty extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.allEmpty;
  final bool changeTaskState = true;
  final bool changeStarState = false;
}

class MotivationalEventTaskCompletedChanged extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.taskCompletedChanged;
  final bool changeTaskState = false;
  final bool changeStarState = true;
  String triggerStarType = 'completedTasks';
}

class MotivationalEventTaskDeletedChanged extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.taskDeletedChanged;
  final bool changeTaskState = false;
  final bool changeStarState = true;
  String triggerStarType = 'deletedTasks';
}

class MotivationalEventTutorialChanged extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.tutorialChanged;
  final bool changeTaskState = false;
  final bool changeStarState = true;
  String triggerStarType = 'tutorial';
}

class MotivationalEventTaskAddedChanged extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.taskAddedChanged;
  final bool changeTaskState = false;
  final bool changeStarState = true;
  String triggerStarType = 'addedTasks';
}
class MotivationalEventObjectiveCompletedChanged extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.objectiveCompleted;
  final bool changeTaskState = false;
  final bool changeStarState = true;
  String triggerStarType = 'objectiveCompleted';
}

class MotivationalEventTutorialCompletedChanged extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.tutorialCompleted;
  final bool changeTaskState = false;
  final bool changeStarState = true;
  String triggerStarType = 'tutorial';
}

class MotivationalEventDayStreakChanged extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.dayStreakChanged;
  final bool changeTaskState = false;
  final bool changeStarState = true;
  String triggerStarType = 'MotiStatDayStreak';
}

class MotivationalEventJumpChanged extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.jumpChanged;
  final bool changeTaskState = false;
  final bool changeStarState = true;
  String triggerStarType = 'jumps';
}

class MotivationalEventPhotoAddedChanged extends MotivationalEvent {
  MotivationalEventType type = MotivationalEventType.photoAddedChanged;
  final bool changeTaskState = false;
  final bool changeStarState = true;
  String triggerStarType = 'addedPhotos';
}
