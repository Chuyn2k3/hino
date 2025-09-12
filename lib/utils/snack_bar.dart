import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../widget/notify/flush_bar_interactive_modal.dart';

extension Snackbar on BuildContext {
  Future<void> showSnackBarFail({
    required String text,
    bool positionTop = true,
  }) async {
    final flushBar = FlushBarInteractiveModal(
      title: null,
      message: text,
      flushBarPosition:
          positionTop ? FlushbarPosition.TOP : FlushbarPosition.BOTTOM,
    );
    await flushBar.showFailure(this);

    // Waiting for flushbar show
    await Future.delayed(FlushBarInteractiveModal.displayDuration);

    // Waiting for flushbar dismiss
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> showSnackBarSuccess({
    required String text,
    bool positionTop = true,
    Function(Flushbar flushbar)? ontap,
  }) async {
    final flushBar = FlushBarInteractiveModal(
      title: null,
      message: text,
      flushBarPosition:
          positionTop ? FlushbarPosition.TOP : FlushbarPosition.BOTTOM,
    );
    await flushBar.showSuccess(this);

    // Waiting for flushbar show
    await Future.delayed(FlushBarInteractiveModal.displayDuration);

    // Waiting for flushbar dismiss
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> showSnackBarInfo({
    required String text,
    bool positionTop = true,
    Function(Flushbar flushbar)? ontap,
  }) async {
    final flushBar = FlushBarInteractiveModal(
      title: null,
      message: text,
      flushBarPosition:
          positionTop ? FlushbarPosition.TOP : FlushbarPosition.BOTTOM,
    );
    await flushBar.showSuccess(this);

    // Waiting for flushbar show
    await Future.delayed(FlushBarInteractiveModal.displayDuration);

    // Waiting for flushbar dismiss
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // void showSnackBarSuccessCustom(
  //         {required String text,
  //         bool? positionTop,
  //         VoidCallback? goToDetails,
  //         Function(Flushbar flushbar)? ontap}) =>
  //     Flushbar(
  //       icon: const Icon(
  //         Icons.check_circle,
  //         color: Colors.white,
  //       ),
  //       shouldIconPulse: false,
  //       message: text,
  //       onTap: ontap,
  //       messageText: Text(
  //         text,
  //         style: textTheme.t16R.copyWith(color: Colors.white),
  //         textAlign: TextAlign.left,
  //         overflow: TextOverflow.ellipsis,
  //         maxLines: 2,
  //       ),
  //       mainButton: Row(
  //         children: [
  //           Container(
  //             margin: const EdgeInsets.only(right: 8),
  //             decoration: BoxDecoration(
  //               color: const Color.fromRGBO(255, 255, 255, 0.2),
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             width: 103,
  //             height: 32,
  //             child: Center(
  //               child: InkWell(
  //                 onTap: () {
  //                   goToDetails?.call();
  //                 },
  //                 child: Text(
  //                   S.current.view_details,
  //                   style: textTheme.t14M.copyWith(color: Colors.white),
  //                   textAlign: TextAlign.center,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(
  //             width: 8,
  //           ),
  //           Container(
  //             height: 42,
  //             width: 1,
  //             color: Colors.white,
  //           ),
  //           const SizedBox(
  //             width: 8,
  //           ),
  //           GestureDetector(
  //             onTap: () {
  //               //  Navigator.pop(context);
  //             },
  //             child: SvgPicture.asset(
  //               Assets.newAssets.icons.closeAction,
  //               colorFilter: const ColorFilter.mode(
  //                 Colors.white,
  //                 BlendMode.srcIn,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       backgroundColor: Colors.green,
  //       borderRadius: BorderRadius.circular(16),
  //       duration: const Duration(seconds: 2),
  //       margin: const EdgeInsets.all(8),
  //       flushbarPosition: FlushbarPosition.TOP,
  //     )..show(this);
}
