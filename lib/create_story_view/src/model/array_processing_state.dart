abstract class ArrayProcessingState {
  const ArrayProcessingState();

  int get totalSteps;
  int get currentStep;
  String? get message;

  double get progress => currentStep / totalSteps;

  int get percentage => (progress * 100).toInt();
}
