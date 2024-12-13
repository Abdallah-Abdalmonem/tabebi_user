import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/cubits/searchCubit.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/designConfig.dart';
import 'package:tabebi/helper/sessionManager.dart';
import 'package:tabebi/models/doctor.dart';
import 'package:tabebi/models/hospital.dart';
import 'package:tabebi/models/lab.dart';

import '../../app/routes.dart';
import '../../cubits/specialityCubit.dart';
import '../../helper/constant.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';
import '../../models/speciality.dart';

class SearchContentPage extends StatefulWidget {
  const SearchContentPage({Key? key}) : super(key: key);

  @override
  SearchContentPageState createState() => SearchContentPageState();
}

class SearchContentPageState extends State<SearchContentPage> {
  TextEditingController edtSearch = TextEditingController();
  List<Doctor> recentdrlist = [];
  List<Lab> recentlablist = [];
  List<Hospital> recenthospitallist = [];
  // recentcliniclist = [],
  //  recentcenterlist = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setLocalList();
    });
  }

  setLocalList() {
    if (BlocProvider.of<SpecialityCubit>(context).state is! SpecialitySuccess) {
      BlocProvider.of<SpecialityCubit>(context).loadPosts(context, {});
    }
    recentdrlist.addAll(
        Constant.recentDrlist.map((e) => Doctor.fromSearchJson(e)).toList());
    recentlablist.addAll(
        Constant.recentLablist.map((e) => Lab.fromSearchJson(e)).toList());
    recenthospitallist.addAll(Constant.recentHospitallist
        .map((e) => Hospital.fromDrJsonfromJson(e))
        .toList());
    /* recentcliniclist.addAll(Constant.recentCliniclist
        .map((e) => Hospital.fromDrJsonfromJson(e))
        .toList());
    recentcenterlist.addAll(Constant.recentCenterlist
        .map((e) => Hospital.fromDrJsonfromJson(e))
        .toList());*/

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(lblSearch), context),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            GeneralWidgets.searchWidget(
                edtSearch, context, getLables(homescreenSearchLbl),
                onSearchTextChanged: onSearchTextChanged),
            Expanded(child: contentWidget())
          ])),
    );
  }

  onSearchTextChanged(String text) async {
    if (text.trim().isEmpty) {
      BlocProvider.of<SearchCubit>(context).setEmptyList();
      return;
    }

    BlocProvider.of<SearchCubit>(context)
        .getSearchList(context, {ApiParams.search: text});
  }

  contentWidget() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (edtSearch.text.trim().isEmpty) {
          return recentList();
        } else if (state is SearchProgress) {
          return GeneralWidgets.loadingIndicator();
        } else if (state is SearchFailure) {
          return Center(
            child: Text(state.errorMessage),
          );
        } else if (state is SearchSuccess) {
          return listContent(state);
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  recentList() {
    return ListView(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 3),
        children: [
          if (recentdrlist.isNotEmpty || recenthospitallist.isNotEmpty)
            Row(children: [
              Expanded(
                  child:
                      headerWidget(lblRecentSearches, txtcolor: primaryColor)),
              TextButton(
                  style: TextButton.styleFrom(
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .apply(color: grey)),
                  onPressed: () {
                    recentdrlist.clear();
                    recenthospitallist.clear();
                    recentlablist.clear();
                    GeneralMethods.clearRecentHistory();
                    setState(() {});
                  },
                  child: Text(getLables(lblClearAll)))
            ]),
          if (recentdrlist.isNotEmpty) drWidget(recentdrlist, fromRecent: true),
          if (recenthospitallist.isNotEmpty)
            hospitalWidget(recenthospitallist,
                "${getLables(lblHospitals)}/${getLables(lblCenter)}/${getLables(lblClinic)}",
                fromRecent: true, translated: true),
          if (recentlablist.isNotEmpty)
            labWidget(recentlablist, fromRecent: true),
          /* 
          if (recenthospitallist.isNotEmpty)
            hospitalWidget(recenthospitallist, lblHospitals, fromRecent: true),
         if (recentlablist.isNotEmpty)
            labWidget(recentlablist, fromRecent: true),
          if (recentcenterlist.isNotEmpty)
            hospitalWidget(recentcenterlist, lblCenters, fromRecent: true),
          if (recentcliniclist.isNotEmpty)
            hospitalWidget(recentcliniclist, lblClinics, fromRecent: true),*/

          specialityWidget(),
        ]);
  }

  specialityWidget() {
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - (11.7 * kToolbarHeight)) / 2;
    // final double itemWidth = (size.width) / 2;
    final double itemWidth = (size.width - 12) / 2;

    return BlocBuilder<SpecialityCubit, SpecialityState>(
      builder: (context, state) {
        if (state is SpecialityProgress && state.isFirstFetch) {
          return SizedBox.shrink();
        } else if (state is SpecialityFailure) {
          return SizedBox.shrink();
        }
        List<Speciality> posts = [];

        if (state is SpecialityProgress) {
          posts = state.oldSpecialityList;
        } else if (state is SpecialitySuccess) {
          posts = state.specialityList;
        }
        if (posts.isEmpty) return SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            headerWidget(lblSearchBySpeciality),
            const SizedBox(height: 5),
            GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                shrinkWrap: true,
                //childAspectRatio: (itemWidth / itemHeight),
                childAspectRatio: 2.5,
                physics: NeverScrollableScrollPhysics(),
                children: List.generate(posts.length, (index) {
                  Speciality post = posts[index];
                  return GeneralWidgets.cardBoxWidget(
                      celevation: 0,
                      cpadding: EdgeInsetsDirectional.symmetric(vertical: 8),
                      childWidget: GestureDetector(
                        onTap: () {
                          Constant.drGetListParams = {};
                          Constant.drGetListParams[ApiParams.specialityId] =
                              post.id.toString();

                          GeneralMethods.goToNextPage(
                            Routes.doctorlistpage,
                            context,
                            false,
                          );
                        },
                        child: Row(children: [
                          const SizedBox(width: 10),
                          GeneralWidgets.circularImage(post.image),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(
                            post.name!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ))
                        ]),
                      ));
                })),
          ],
        );
      },
    );
  }

  listContent(SearchSuccess state) {
    return ListView(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 3),
        children: [
          if (state.drlist.isNotEmpty) drWidget(state.drlist),
          if (state.hospitallist.isNotEmpty)
            hospitalWidget(state.hospitallist, lblHospitals,
                sessionname: SessionManager.recentHospital,
                recentlist: Constant.recentHospitallist),
          if (state.lablist.isNotEmpty) labWidget(state.lablist),
          if (state.centerlist.isNotEmpty)
            hospitalWidget(state.centerlist, lblCenters,
                sessionname: SessionManager.recentHospital,
                recentlist: Constant.recentHospitallist),
          if (state.cliniclist.isNotEmpty)
            hospitalWidget(state.cliniclist, lblClinics,
                sessionname: SessionManager.recentHospital,
                recentlist: Constant.recentHospitallist),
        ]);
  }

  drWidget(List<Doctor> drlist, {bool fromRecent = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: fromRecent ? 5 : 20),
      headerWidget(lblDoctors),
      const SizedBox(height: 15),
      if (fromRecent)
        localListWidget(drlist, redirectToDr, Constant.recentDrlist,
            SessionManager.recentDr)
      else
        serverListWidget(drlist, redirectToDr, Constant.recentDrlist,
            SessionManager.recentDr)
      /* Wrap(
            runSpacing: 8,
            children: List.generate(
                drlist.length,
                (index) => GeneralWidgets.setListtileMenu(
                        Constant.session!.getCurrLangCode() ==
                                Constant.arabicLanguageCode
                            ? drlist[index].nameAr!
                            : drlist[index].nameEng!,
                        context,
                        titleMaxline: 1,
                        titleTextoverflow: TextOverflow.ellipsis,
                        shapeBorder: DesignConfig.setRoundedBorder(8, false),
                        leadingwidget: GeneralWidgets.circularImage(
                            drlist[index].image,
                            height: 42,
                            width: 42),
                        subtextstyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .apply(color: grey),
                        desc:
                            "${drlist[index].speciality!.name}, ${drlist[index].subspecialties!.join(", ")}",
                        onClickAction: () async {
                      redirectToDr(
                          drlist[index].id.toString(),
                          fromRecent,
                          drlist[index].toMap(),
                          Constant.recentDrlist,
                          SessionManager.recentDr);
                    })))*/
    ]);
  }

  headerWidget(String lbl, {bool translated = false, Color? txtcolor}) {
    return Text(
      translated ? lbl : getLables(lbl),
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .apply(color: txtcolor ?? lightGrey),
    );
  }

  hospitalWidget(List<Hospital> list, String lbls,
      {bool fromRecent = false,
      String sessionname = "",
      List? recentlist,
      bool translated = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: fromRecent ? 5 : 20),
      headerWidget(lbls, translated: translated),
      const SizedBox(height: 15),
      if (fromRecent)
        localListWidget(list, redirectToHospital, recentlist ?? [], sessionname)
      else
        serverListWidget(
            list, redirectToHospital, recentlist ?? [], sessionname)

      /* Wrap(
            runSpacing: 8,
            children: List.generate(
                list.length,
                (index) => GeneralWidgets.setListtileMenu(
                        list[index].name!, context,
                        titleMaxline: 1,
                        titleTextoverflow: TextOverflow.ellipsis,
                        shapeBorder: DesignConfig.setRoundedBorder(8, false),
                        leadingwidget: GeneralWidgets.circularImage(
                            list[index].image,
                            height: 42,
                            width: 42),
                        subtextstyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .apply(color: grey),
                        desc: list[index].address!, onClickAction: () async {
                      redirectToHospital(list[index].id!.toString(), fromRecent,
                          list[index].toMap(), recentlist ?? [], sessionname);
                    })))*/
    ]);
  }

  localListWidget(
      List list, Function callback, List recentlist, String sessionname) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) {
          return SizedBox(width: 20);
        },
        itemCount: list.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              callback(list[index].id!.toString(), true, list[index].toMap(),
                  recentlist, sessionname);
            },
            child: SizedBox(
              width: 80,
              child: Column(children: [
                GeneralWidgets.circularImage(list[index].image,
                    height: 42, width: 42),
                const SizedBox(height: 3),
                Text(
                  list[index].name!,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ]),
            ),
          );
        },
      ),
    );
  }

  serverListWidget(
      List list, Function callback, List recentlist, String sessionname) {
    return Wrap(
        runSpacing: 8,
        children: List.generate(
            list.length,
            (index) => GeneralWidgets.setListtileMenu(
                    list[index].name!, context,
                    titleMaxline: 1,
                    titleTextoverflow: TextOverflow.ellipsis,
                    shapeBorder: DesignConfig.setRoundedBorder(8, false),
                    leadingwidget: GeneralWidgets.circularImage(
                        list[index].image,
                        height: 42,
                        width: 42),
                    subtextstyle: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .apply(color: grey),
                    desc: list[index].searchSubText!, onClickAction: () async {
                  callback(list[index].id!.toString(), false,
                      list[index].toMap(), recentlist, sessionname);
                })));
  }

  redirectLabDetail(String id, bool fromRecent, Map<String, dynamic> mapitem,
      List recentlist, String sessionname) async {
    if (!fromRecent) {
      await GeneralMethods.addRecentData(
          recentlist, int.parse(id), sessionname, mapitem);
    }
    GeneralMethods.goToNextPage(Routes.labDetailPage, context, false,
        args: {"labId": id, "fromSelectTest": false});
  }

  redirectToDr(String id, bool fromRecent, Map<String, dynamic> mapitem,
      List recentlist, String sessionname) async {
    if (!fromRecent) {
      await GeneralMethods.addRecentData(
          Constant.recentDrlist, int.parse(id), sessionname, mapitem);
    }

    GeneralMethods.goToNextPage(Routes.doctorDetailPage, context, false,
        args: {"drId": id});
  }

  redirectToHospital(String id, bool fromRecent, Map<String, dynamic> mapitem,
      List recentlist, String sessionname) async {
    if (!fromRecent) {
      await GeneralMethods.addRecentData(
          recentlist, int.parse(id), sessionname, mapitem);
    }
    GeneralMethods.goToNextPage(Routes.hospitalDetailPage, context, false,
        args: {"hospitalId": id});
  }

  labWidget(List<Lab> list, {bool fromRecent = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: fromRecent ? 5 : 20),
      headerWidget(lblLabs),
      const SizedBox(height: 15),
      if (fromRecent)
        localListWidget(list, redirectLabDetail, Constant.recentLablist,
            SessionManager.recentLab)
      else
        serverListWidget(list, redirectLabDetail, Constant.recentLablist,
            SessionManager.recentLab)
      /* Wrap(
            runSpacing: 8,
            children: List.generate(
                list.length,
                (index) => GeneralWidgets.setListtileMenu(
                        list[index].name!, context,
                        titleMaxline: 1,
                        titleTextoverflow: TextOverflow.ellipsis,
                        shapeBorder: DesignConfig.setRoundedBorder(8, false),
                        leadingwidget: GeneralWidgets.circularImage(
                            list[index].image,
                            height: 42,
                            width: 42),
                        subtextstyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .apply(color: grey),
                        desc: list[index].address!, onClickAction: () async {
                      redirectLabDetail(
                          list[index].id!.toString(),
                          fromRecent,
                          list[index].toMap(),
                          Constant.recentLablist,
                          SessionManager.recentLab);
                    })))*/
    ]);
  }
}
