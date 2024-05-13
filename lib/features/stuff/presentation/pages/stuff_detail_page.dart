import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stocktacking/app/routing_provider.dart';
import 'package:stocktacking/core/presentation/app_bar/build_app_bar.dart';
import 'package:stocktacking/core/presentation/panel/panel.dart';
import 'package:stocktacking/core/routing/constants/routing_names.dart';
import 'package:stocktacking/core/routing/constants/routing_params.dart';
import 'package:stocktacking/features/stuff/presentation/providers/stuff_providers.dart';
import '../../../../core/presentation/action_button/action_button.dart';

class StuffDetailPage extends ConsumerWidget {

  final int stuffId;

  const StuffDetailPage(this.stuffId, {super.key});

  void Function() _buildOnHistoryTap(WidgetRef ref) => () => ref
      .read(locationServiceProvider)
      .goNamed(name: stuffHistory, params: {stuffIdParam: stuffId.toString()});

  void Function() _buildOnPutTap(WidgetRef ref) => () => ref
      .read(locationServiceProvider)
      .goNamed(name: stuffReport, params: {stuffIdParam: stuffId.toString(), stuffReportIsPutParam: true.toString()});

  void Function() _buildOnQrTap(WidgetRef ref) => () => ref
      .read(locationServiceProvider)
      .goNamed(name: stuffPhysicalIdentifier, params: {stuffIdParam: stuffId.toString()});

  @override
  Widget build(BuildContext context, ref) {
    final getStuffRes = ref.watch(getStuffByIdProvider.call(stuffId));

    return Scaffold(
      appBar: buildAppBar(
          context: context,
          title: 'Предмет',
          actions: [
            ActionButton(icon: Icons.history, onTap: _buildOnHistoryTap(ref)),
            ActionButton(onTap: _buildOnQrTap(ref), icon: Icons.qr_code_outlined)
          ]
      ),
      bottomNavigationBar: switch(getStuffRes) {
        AsyncData(:final value) =>  Panel(
          child: Row(
            children:[
              Expanded(
                child: ElevatedButton(
                    onPressed: _buildOnPutTap(ref),
                    child: const Text('Положить')
                ),
              )
            ],
          ),
        ),
        _ => null
      },
      body: switch(getStuffRes) {
        AsyncData(:final value) =>  SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Panel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(value.title, style: Theme.of(context).textTheme.displayLarge,),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Находится'),
                          Text(value.fullStorageName),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ExpansionTile(
                        title: Text('Фото предмета', style: Theme.of(context).textTheme.displayMedium,),
                        childrenPadding: const EdgeInsets.all(16),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            side: BorderSide(color: Color(0x1113181A), width: 1)
                        ),
                        collapsedShape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            side: BorderSide(color: Color(0x1113181A), width: 1)
                        ),
                        children: [
                          Image.network(
                            value.image,
                            fit: BoxFit.contain,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Panel(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: value.isBroken
                                    ? const Color(0xFFFF4545)
                                    : const Color(0xFF3FE06C),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(50),
                                    bottom:  Radius.circular(50)
                                ),
                              ),
                              child: const SizedBox(width: 8, height: 28),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Состояние',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        value.isBroken
                            ? Text('Обнаружена неполадка (${value.comment ?? 'Не указано'})')
                            : const Text('Неполадок не обнаружено')
                      ],
                    )
                ),
                const SizedBox(height: 14),
                Panel(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Доп. информация',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 14),
                        ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (_, index) => ExpansionTile(
                                title: Text(value.options[index].title, style: Theme.of(context).textTheme.displayMedium),
                                childrenPadding: const EdgeInsets.all(16),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(16)),
                                    side: BorderSide(color: Color(0x1113181A), width: 1)
                                ),
                                collapsedShape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(16)),
                                    side: BorderSide(color: Color(0x1113181A), width: 1)
                                ),
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(value.options[index].text, textAlign: TextAlign.start,),
                                  )
                                ]
                            ),
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemCount: value.options.length
                        )
                      ],
                    )
                )
              ],
            ),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator())
      }
    );
  }
}
