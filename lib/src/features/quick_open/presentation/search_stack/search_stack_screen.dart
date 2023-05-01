// Copyright (c) 2023 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/two_finger_pointer.dart';
import '../quick_search/quick_search_screen.dart';

class ShowQuickOpenIntent extends Intent {}

class HideQuickOpenIntent extends Intent {}

class SearchStackScreen extends HookWidget {
  const SearchStackScreen({super.key, this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    final visible = useState(false);
    final focus = useFocusNode();
    useEffect(() {
      if (!visible.value) {
        focus.requestFocus();
      }
      return null;
    }, [visible.value]);
    return QuickSearchShortcutWrapper(
      visible: visible,
      child: Stack(
        children: [
          if (child != null)
            Focus(
              autofocus: true,
              focusNode: focus,
              child: child!,
            ),
          if (visible.value)
            GestureDetector(
              onTap: () => visible.value = false,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  decoration: BoxDecoration(
                    color: context.theme.canvasColor.withOpacity(.1),
                  ),
                  child: QuickSearchScreen(
                    afterClick: () => visible.value = false,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QuickSearchShortcutWrapper extends StatelessWidget {
  const QuickSearchShortcutWrapper({
    super.key,
    required this.child,
    required this.visible,
  });
  final Widget child;
  final ValueNotifier<bool> visible;
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        SingleActivator(
          LogicalKeyboardKey.keyP,
          control: !Platform.isMacOS,
          meta: Platform.isMacOS,
        ): ShowQuickOpenIntent(),
        const SingleActivator(LogicalKeyboardKey.escape): HideQuickOpenIntent(),
      },
      child: Actions(
        actions: {
          ShowQuickOpenIntent: CallbackAction<ShowQuickOpenIntent>(
            onInvoke: (ShowQuickOpenIntent intent) {
              visible.value = true;
              return null;
            },
          ),
          HideQuickOpenIntent: CallbackAction<HideQuickOpenIntent>(
            onInvoke: (HideQuickOpenIntent intent) {
              visible.value = false;
              return null;
            },
          ),
        },
        child: TwoFingerPointerWidget(
          onUpdate: (details) => visible.value = true,
          child: child,
        ),
      ),
    );
  }
}