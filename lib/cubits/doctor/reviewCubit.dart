import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/constant.dart';
import '../../helper/customException.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';
import '../../models/review.dart';

abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewProgress extends ReviewState {
  final List<Review> oldReviewList;
  final bool isFirstFetch;
  final int currOffset;
  final int currPage;
  ReviewProgress(this.oldReviewList, this.currOffset, this.currPage,
      {this.isFirstFetch = false});
}

class ReviewSuccess extends ReviewState {
  List<Review> reviewList;
  final int currOffset;
  final int currPage;
  final int total;
  ReviewSuccess(
      {required this.reviewList,
      required this.currOffset,
      required this.currPage,
      required this.total});
}

class ReviewFailure extends ReviewState {
  final String errorMessage;
  ReviewFailure(this.errorMessage);
}

class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit() : super(ReviewInitial());
  int page = 1;
  int offset = 0;
  bool isLoadmore = true;

  setInitialState() {
    page = 1;
    offset = 0;
    isLoadmore = true;
    emit(ReviewInitial());
  }

  setOldList(int offsetval, int pageno, int total, List<Review> splist) {
    print("emptry-search--seltold==${splist.length}");
    page = pageno;
    offset = offsetval;
    isLoadmore = true;

    emit(ReviewSuccess(
        reviewList: splist, currOffset: offset, total: total, currPage: page));
  }

  loadPosts(BuildContext context, Map<String, String?> parameter) {
    print("pageno*==$state===$offset==Size==$isLoadmore");
    if (state is ReviewProgress || !isLoadmore) return;

    final currentState = state;

    var oldPosts = <Review>[];
    if (currentState is ReviewSuccess) {
      oldPosts = currentState.reviewList;
      print(
          "pageno==${currentState.currOffset}===$offset==Size==${oldPosts.length}");
    }

    //emit(ReviewProgress(oldPosts, page, isFirstFetch: page == 1));
    //parameter[ApiParams.page] = page.toString();
    emit(ReviewProgress(oldPosts, offset, page, isFirstFetch: offset == 0));

    parameter[ApiParams.page] = page.toString();
    parameter[ApiParams.offset] = offset.toString();
    parameter[ApiParams.limit] = Constant.fetchLimit.toString();

    fetchReviewByPage(parameter, context).then((newPosts) {
      List<Review> posts = [];
      //if (page != 1) {
      if (offset != 0 && state is ReviewProgress) {
        posts = (state as ReviewProgress).oldReviewList;
      }
      posts.addAll(newPosts["list"]);
      //int currpage = page;
      int currpage = page;
      int curroffset = offset;
     
      if (newPosts["total"] > posts.length) {
        page++;
        offset = offset + Constant.fetchLimit;
        isLoadmore = true;
      } else {
        isLoadmore = false;
      }
      emit(ReviewSuccess(
          reviewList: posts,
          currOffset: curroffset,
          total: newPosts["total"],
          currPage: currpage));
      //emit(ReviewSuccess(ReviewList: posts, currPage: currpage));
    }).catchError((e) {
      isLoadmore = false;
      if (offset == 0) emit(ReviewFailure(e.toString()));
      //if (page == 1) emit(ReviewFailure(e.toString()));
    });
  }

  Future<Map> fetchReviewByPage(
      Map<String, String?> parameter, BuildContext context) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      throw CustomException(getLables(noInternetErrorMessage));
    } else {
      var response = await Api.sendApiRequest(
          ApiParams.apiGetReview, parameter, true, context);
     
      if (response == null) {
        throw CustomException(getLables(dataNotFoundErrorMessage));
      } else {
        var getdata = json.decode(response);
        if (getdata[ApiParams.error]) {
          throw CustomException(getdata[ApiParams.message]);
        } else {
          List data = getdata['data'];
          List<Review> favlist = [];
          favlist.addAll(data.map((e) => Review.fromMap(e)).toList());
          return {"list": favlist, "total": getdata["total"]};
        }
      }
    }
  }
}
