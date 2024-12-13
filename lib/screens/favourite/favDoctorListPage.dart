import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/helper/stringLables.dart';
import '../../app/routes.dart';
import '../../cubits/doctor/favouriteDoctorCubit.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../models/favouriteData.dart';

class FavDoctorListPage extends StatefulWidget {
  final String type;
  const FavDoctorListPage({Key? key, required this.type}) : super(key: key);

  @override
  FavDoctorListPageState createState() => FavDoctorListPageState();
}

class FavDoctorListPageState extends State<FavDoctorListPage>
    with AutomaticKeepAliveClientMixin {
  List<FavouriteData> loadedlist = [];
  final scrollController = ScrollController();
  int loadedpage = 1, loadedoffset = 0;

  @override
  void initState() {
    super.initState();

    setupScrollController(context);
    if (BlocProvider.of<FavDoctorCubit>(context).state is! FavDoctorLoaded) {
      print("loadstate");
      loadPage();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadPage({bool isSetInitial = false}) {
    BlocProvider.of<FavDoctorCubit>(context).loadPosts(
        context, {ApiParams.type: widget.type},
        isSetInitial: isSetInitial);
    print("currpage=${BlocProvider.of<FavDoctorCubit>(context).page}");
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
    super.build(context);
    return contentWidget();
  }

  contentWidget() {
    return BlocBuilder<FavDoctorCubit, FavDoctorState>(
      builder: (context, state) {
        print("state->fav-$state");
        if (state is FavDoctorLoading && state.isFirstFetch) {
          return GeneralWidgets.loadingIndicator();
        } else if (state is FavDoctorFailure) {
          return GeneralWidgets.msgWithTryAgain(
              state.errorMessage, () => loadPage(isSetInitial: true));
        }
        return listContent(state);
      },
    );
  }

  listContent(FavDoctorState state) {
    List<FavouriteData> posts = [];
    bool isLoading = false;
    int currpage = 1;
    if (state is FavDoctorLoading) {
      posts = state.oldDrList;
      isLoading = true;
      currpage = state.currPage;
    } else if (state is FavDoctorLoaded) {
      posts = state.favDoctorList;
      currpage = state.currPage;
    }

    if (posts.isNotEmpty) {
      loadedpage = currpage;
      loadedlist = [];
      loadedlist = posts;
    }

    return RefreshIndicator(
      onRefresh: refreshList,
      child: ListView.separated(
        controller: scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index < posts.length)
            return drListItemWidget(posts[index], index);
          else {
            Timer(Duration(milliseconds: 30), () {
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
            });

            return GeneralWidgets.loadingIndicator();
          }
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 10,
          );
        },
        itemCount: posts.length + (isLoading ? 1 : 0),
      ),
    );
  }

  drListItemWidget(FavouriteData post, int index) {
    return GeneralWidgets.setListtileMenu("", context,
        titlwidget: Row(children: [
          Expanded(
            child: Text(
              Constant.session!.getCurrLangCode() == Constant.arabicLanguageCode
                  ? post.favouriteData!.nameAr!
                  : post.favouriteData!.nameEng!,
              style: Theme.of(context).textTheme.titleMedium!.merge(TextStyle(
                  color: black,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5)),
            ),
          ),
          Icon(
            Icons.favorite,
            color: primaryColor,
            size: 20,
          )
        ]),
        lcontentPadding:
            EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 10),
        discwidget:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "${post.favouriteData!.totalAppointments} ${getLables(lblAppointments)}",
            style: TextStyle(color: grey),
          ),
          const SizedBox(height: 5),
          GeneralWidgets.rateReviewCountWidget(context,
              post.favouriteData!.rates!, post.favouriteData!.totalReviews!),
        ]), onClickAction: () {
      if (widget.type == Constant.appointmentDoctor) {
        GeneralMethods.goToNextPage(Routes.doctorDetailPage, context, false,
            args: {
              "drId": post.favouriteData!.id.toString(),
              "favIndex": index,
              "favcubit": context.read<FavDoctorCubit>()
            });
      } else {
        GeneralMethods.goToNextPage(Routes.labDetailPage, context, false,
            args: {
              "labId": post.favouriteData!.id.toString(),
              "favIndex": index,
              "fromSelectTest": false,
              "favcubit": context.read<FavDoctorCubit>()
            });
      }
    },
        leadingwidget: GeneralWidgets.circularImage(post.favouriteData!.image,
            height: 60, width: 50));
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> refreshList() async {
    loadPage(isSetInitial: true);
  }
}
