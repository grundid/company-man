import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smallbusiness/share/share_cubit.dart';

class ShareableContent {
  final String fileName;
  final List<int> data;

  ShareableContent(this.fileName, this.data);
}

typedef ShareableBuilder = Future<ShareableContent?> Function();

class ShareWidget extends StatelessWidget {
  final ShareableBuilder shareableBuilder;

  const ShareWidget({Key? key, required this.shareableBuilder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShareCubit(shareableBuilder),
      child: BlocBuilder<ShareCubit, ShareState>(
        builder: (context, state) {
          return IconButton(
              onPressed: () {
                context.read<ShareCubit>().share();
              },
              icon: Icon(Icons.share));
        },
      ),
    );
  }
}
