import 'package:flutter/material.dart';
import 'package:mikack/models.dart' as models;

class ComicsView extends StatelessWidget {
  ComicsView(this.comics,
      {this.onTap,
      this.onLongPress,
      this.inStackItemBuilders = const [],
      this.scrollController,
      this.httpHeaders});

  final List<models.Comic> comics;
  final Function(models.Comic) onTap;
  final Function(models.Comic) onLongPress;
  final List<Widget Function(models.Comic)> inStackItemBuilders;
  final ScrollController scrollController;
  final Map<String, String> httpHeaders;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 2,
        children: List.generate(comics.length, (index) {
          return Card(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 图片
                Image.network(
                  comics[index].cover,
                  fit: BoxFit.cover,
                  headers: httpHeaders,
                ),
                // 文字
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 5, top: 20, right: 5, bottom: 5),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                          Color.fromARGB(120, 0, 0, 0),
                          Colors.transparent,
                        ])),
                    child: Center(
                      child: Text(comics[index].title,
                          style: TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
                // 点击事件/效果
                Positioned.fill(
                    child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap == null ? null : onTap(comics[index]),
                    onLongPress: () =>
                        onLongPress == null ? null : onLongPress(comics[index]),
                  ),
                )),
                ...inStackItemBuilders.map((f) => f(comics[index])).toList(),
              ],
            ),
          );
        }),
        controller: scrollController);
  }
}
