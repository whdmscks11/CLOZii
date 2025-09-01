import 'package:carrot_login/core/theme/context_extension.dart';
import 'package:carrot_login/core/utils/number_format.dart';
import 'package:carrot_login/core/utils/uploaded_time.dart';
import 'package:carrot_login/core/widgets/custom_button.dart';
import 'package:carrot_login/core/widgets/custom_text_link.dart';
import 'package:carrot_login/features/home/models/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                systemOverlayStyle: SystemUiOverlayStyle.light,
                foregroundColor: context.colors.onPrimary,
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      PageView(
                        children: [
                          ...post.imageUrls.map(
                            (url) => Image.network(url, fit: BoxFit.cover),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Builder(
                          builder: (context) => Container(
                            height:
                                MediaQuery.of(context).padding.top +
                                kToolbarHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black38, Colors.transparent],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(CupertinoIcons.arrowshape_turn_up_right_fill),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('사용자 정보', style: context.textTheme.titleLarge),
                          Text('매너 온도', style: context.textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(indent: 20, endIndent: 20),
                      const SizedBox(height: 10),
                      Text(post.title, style: context.textTheme.titleLarge),
                      const SizedBox(height: 10),
                      post.price != null
                          ? Text(
                              '\u20B1 ${formatPrice(post.price!)}', //₱
                              style: context.textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Row(
                              children: [
                                Text(
                                  'SHARES',
                                  style: context.textTheme.titleLarge!.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: context.colors.primary,
                                ),
                              ],
                            ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CustomTextLink(
                            linkText: 'Category',
                            linkTextStyle: context.textTheme.bodyLarge!
                                .copyWith(
                                  color: context.colors.scrim,
                                  decoration: TextDecoration.underline,
                                  decorationColor: context.colors.scrim,
                                ),
                            onTap: () {},
                          ),
                          Text(' · '),
                          Text(
                            '${showUploadedTime(post.createdAt)} ago',
                            style: context.textTheme.bodyLarge!.copyWith(
                              color: context.colors.scrim,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      if (post.content != null)
                        Text(post.content!, style: context.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: context.colors.shadow),
                    ),
                  ),
                  height: 65,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.favorite_border_outlined,
                            size: 30.0,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: context.colors.shadow,
                              hintText: 'Chat message',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        CustomButton(
                          text: 'Send',
                          onTap: () {},
                          width: 80.0,
                          height: 60.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(height: kToolbarHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
