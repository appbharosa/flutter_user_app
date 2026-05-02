import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/banner_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/banner_event.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BannerBloc>()..add(FetchBanners()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Banners')),
        body: BlocBuilder<BannerBloc, BannerState>(
          builder: (context, state) {
            if (state is BannerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BannerLoaded) {
              return ListView.builder(
                itemCount: state.banners.length,
                itemBuilder: (context, index) {
                  final banner = state.banners[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Image.network(banner.imageUrl),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Position: ${banner.position}'),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is BannerError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BannerBloc>().add(FetchBanners());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}