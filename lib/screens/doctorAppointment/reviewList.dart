import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/helper/stringLables.dart';
import 'package:tabebi/models/review.dart';
import '../../cubits/doctor/reviewCubit.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';

class ReviewList extends StatefulWidget {
  final ReviewCubit reviewCubit;
  final Map<String, String>? mainparameter;
  const ReviewList(
      {Key? key, required this.reviewCubit, required this.mainparameter})
      : super(key: key);

  @override
  ReviewListState createState() => ReviewListState();
}

class ReviewListState extends State<ReviewList> {
  final scrollController = ScrollController();
  TextEditingController edtSearch = TextEditingController();
  List<Review> loadedlist = [];
  int loadedpage = 1, loadedoffset = 0;
  @override
  void initState() {
    super.initState();
    print("init===****review");
    setupScrollController(context);
    if (widget.reviewCubit.state is! ReviewSuccess) {
      print("loadstate===****review");
      loadPage();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadPage({bool isSetInitial = false}) {
    print("currpage=${widget.reviewCubit.offset}==$isSetInitial");
    if (isSetInitial) {
      widget.reviewCubit.setInitialState();
    }
    widget.reviewCubit.loadPosts(context, widget.mainparameter!);
  }

  setupScrollController(context) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          loadPage();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(lblReviews), context),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<ReviewCubit, ReviewState>(
          bloc: widget.reviewCubit,
          builder: (context, state) {
            return contentWidget(state);
          },
        ),
      ),
    );
  }

  contentWidget(ReviewState state) {
    if (state is ReviewProgress && state.isFirstFetch) {
      return GeneralWidgets.loadingIndicator();
    } else if (state is ReviewFailure) {
      return GeneralWidgets.msgWithTryAgain(
          state.errorMessage, () => loadPage(isSetInitial: true));
    }
    return listContent(state);
  }

  reviewDetailDialog(Review review) {
    GeneralWidgets.showAlertDialogue(context, Text(getLables(lblReviews)),
        GeneralWidgets.reviewListItemWidget(review, null, null, context), [],
        cpadding: EdgeInsets.all(0));
  }

  listContent(ReviewState state) {
    List<Review> posts = [];
    bool isLoading = false;
    int currpage = 1;
    int curroffset = 0;
    if (state is ReviewProgress) {
      posts = state.oldReviewList;
      isLoading = true;
      currpage = state.currPage;
      curroffset = state.currOffset;
    } else if (state is ReviewSuccess) {
      posts = state.reviewList;
      currpage = state.currPage;
      curroffset = state.currOffset;
    }

    if (edtSearch.text.trim().isEmpty && posts.isNotEmpty) {
      loadedpage = currpage;
      loadedoffset = curroffset;
      loadedlist = [];
      loadedlist = posts;
    }

    return ListView.separated(
      controller: scrollController,
      separatorBuilder: (context, index) {
        return SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        if (index < posts.length)
          return GeneralWidgets.reviewListItemWidget(
              posts[index], 2, TextOverflow.ellipsis, context,
              reviewDetailDialog: reviewDetailDialog);
        else {
          Timer(Duration(milliseconds: 30), () {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          });

          return GeneralWidgets.loadingIndicator();
        }
      },
      itemCount: posts.length + (isLoading ? 1 : 0),
    );
  }
}
