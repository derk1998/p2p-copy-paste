import 'package:p2p_copy_paste/view_models/button.dart';

class CancelConfirmViewModel {
  CancelConfirmViewModel(
      {required this.title,
      required this.description,
      required void Function() onCancelButtonPressed,
      required void Function() onConfirmButtonPressed,
      String cancelName = 'Cancel',
      String confirmName = 'Confirm',
      this.isContentMarkdown = false})
      : cancelButtonViewModel = ButtonViewModel(
            title: cancelName, onPressed: onCancelButtonPressed),
        confirmButtonViewModel = ButtonViewModel(
            title: confirmName, onPressed: onConfirmButtonPressed);

  final String title;
  final String description;
  bool isContentMarkdown;

  final ButtonViewModel cancelButtonViewModel;
  final ButtonViewModel confirmButtonViewModel;
}
