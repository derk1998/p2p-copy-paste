import 'package:test_webrtc/view_models/button.dart';

class CancelConfirmViewModel {
  CancelConfirmViewModel(
      {required this.title,
      required this.description,
      required void Function() onCancelButtonPressed,
      required void Function() onConfirmButtonPressed})
      : cancelButtonViewModel =
            ButtonViewModel(title: 'Cancel', onPressed: onCancelButtonPressed),
        confirmButtonViewModel = ButtonViewModel(
            title: 'Confirm', onPressed: onConfirmButtonPressed);

  final String title;
  final String description;

  final ButtonViewModel cancelButtonViewModel;
  final ButtonViewModel confirmButtonViewModel;
}
