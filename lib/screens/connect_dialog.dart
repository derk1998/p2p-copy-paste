import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2p_copy_paste/models/invite.dart';
import 'package:p2p_copy_paste/view_models/connect_dialog.dart';
import 'package:p2p_copy_paste/widgets/pure_icon_button.dart';

class ConnectDialog extends ConsumerWidget {
  ConnectDialog(
      {super.key,
      required Invite invite,
      required NavigatorState navigator,
      required Widget Function() getJoinNewInvitePageView})
      : _dependencies = ConnectDialogViewModelDependencies(
            invite: invite, getJoinNewInvitePageView: getJoinNewInvitePageView);

  final ConnectDialogViewModelDependencies _dependencies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider = connectDialogViewModelProvider(_dependencies);
    final AsyncValue<ConnectDialogViewModelData?> state =
        ref.watch(viewModelProvider);
    final viewModel = ref.read(viewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(viewModel.title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: state.isLoading || state.value == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.value!.description),
                    const SizedBox(
                      height: 16,
                    ),
                    if (state.value!.refreshButtonViewModel != null)
                      PureIconButton(
                          viewModel: state.value!.refreshButtonViewModel!)
                  ],
                ),
        ),
      ),
    );
  }
}
