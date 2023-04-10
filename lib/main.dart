import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'api/unsplash_api_service.dart';
import 'bloc/photo_bloc.dart';
import 'bloc/simple_bloc_observer.dart';
import 'constants.dart';
import 'utils/enum.dart';
import 'widgets/bottom_loader.dart';

void main() {
  Bloc.observer = const SimpleBlocObserver();
  runApp(const App());
}

class App extends MaterialApp {
  const App({super.key}) : super(home: const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PhotoBloc(apiService: UnsplashApiService())..add(PhotoFetched()),
      child: const PhotosPage(),
    );
  }
}

class PhotosPage extends StatelessWidget {
  const PhotosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhotoBloc, PhotoState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: Text('Page : ${state.pageNumber}'),
            title: TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(
                hintText: 'Search',
              ),
              onSubmitted: (query) =>
                  context.read<PhotoBloc>().add(PhotoSearched(query)),
            ),
          ),
          body: const PhotosList(),
        );
      },
    );
  }
}

class PhotosList extends StatefulWidget {
  const PhotosList({super.key});

  @override
  State<PhotosList> createState() => _PhotosListState();
}

class _PhotosListState extends State<PhotosList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhotoBloc, PhotoState>(
      builder: (context, state) {
        switch (state.status) {
          case PhotoStatus.failure:
            return const Center(child: Text('failed to fetch posts'));
          case PhotoStatus.success:
            if (state.photos.isEmpty) {
              return const Center(child: Text('no posts'));
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                return index >= state.photos.length
                    ? const BottomLoader()
                    : Image.network(state.photos[index].urls[Constants.smallS3],
                        fit: BoxFit.cover);
              },
              itemCount: state.hasReachedMax
                  ? state.photos.length
                  : state.photos.length + 1,
              controller: _scrollController,
            );
          case PhotoStatus.initial:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<PhotoBloc>().add(PhotoFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
