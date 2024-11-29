import 'package:flutter/foundation.dart';
import 'array_processing_state.dart';

enum StoryProcessingStatus {
  processing,
  success,
  error,
}

@immutable
final class StoryProcessingState extends ArrayProcessingState {
  const StoryProcessingState({
    required this.totalSteps,
    required this.currentStep,
    this.message,
    this.stepProgress = 0.0,
    this.status = StoryProcessingStatus.processing,
  }) : assert(totalSteps > 0, 'Total steps cannot be less then 1');

  factory StoryProcessingState.initial() => const StoryProcessingState(
        totalSteps: 1,
        currentStep: 1,
      );

  @override
  final int totalSteps;
  @override
  final int currentStep;
  @override
  final String? message;
  final double stepProgress;
  final StoryProcessingStatus status;

  @override
  double get progress {
    if (totalSteps <= 0 || currentStep > totalSteps) {
      return 0.0;
    }
    return ((currentStep - 1 + stepProgress) / totalSteps).clamp(0.0, 1.0);
  }

  StoryProcessingState copyWith({
    int? totalSteps,
    int? currentStep,
    String? message,
    double? stepProgress,
    StoryProcessingStatus? status,
  }) =>
      StoryProcessingState(
        totalSteps: totalSteps ?? this.totalSteps,
        currentStep: currentStep ?? this.currentStep,
        message: message ?? this.message,
        stepProgress: stepProgress ?? this.stepProgress,
        status: status ?? this.status,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryProcessingState &&
          runtimeType == other.runtimeType &&
          totalSteps == other.totalSteps &&
          currentStep == other.currentStep &&
          message == other.message &&
          stepProgress == other.stepProgress &&
          status == other.status;

  @override
  int get hashCode => Object.hash(totalSteps, currentStep, message, stepProgress, status);
}
