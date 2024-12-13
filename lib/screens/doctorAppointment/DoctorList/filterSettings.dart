import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/stringLables.dart';
import 'package:tabebi/models/speciality.dart';
import '../../../cubits/doctor/doctorCubit.dart';
import '../../../cubits/specialityCubit.dart';
import '../../../helper/apiParams.dart';
import '../../../helper/colors.dart';
import '../../../helper/constant.dart';
import '../../../helper/generalMethods.dart';

class FilterSettings extends StatefulWidget {
  final DoctorCubit doctorCubit;
  const FilterSettings({Key? key, required this.doctorCubit}) : super(key: key);

  @override
  State<FilterSettings> createState() => _FilterSettingsState();
}

class _FilterSettingsState extends State<FilterSettings> {
  String gender = "",
      availability = "",
      availabilityVal = "",
      specialityid = "",
      entity = "";
  String mgender = "",
      mavailability = "",
      mavailabilityVal = "",
      mspecialityid = "",
      mentity = "";
  int specialityoffset = 0, specialityCurrPageTotal = 10, loadedPage = 1;
  List<Speciality> specialitylist = [];
  PageController pageController = PageController();
  final StreamController sc = StreamController();

  @override
  void initState() {
    super.initState();
    specialitylist = [];
    if (BlocProvider.of<SpecialityCubit>(context).state is SpecialitySuccess) {
      SpecialitySuccess successstate =
          BlocProvider.of<SpecialityCubit>(context).state as SpecialitySuccess;
      specialitylist.addAll(successstate.specialityList);
      loadedPage = successstate.currPage;
    }

    gender = Constant.drGetListParams[ApiParams.gender] ?? "";
    specialityid = Constant.drGetListParams[ApiParams.specialityId] ?? "";
    entity = Constant.drGetListParams[ApiParams.entity] ?? "";
    availabilityVal = Constant.drGetListParams["availabilityVal"] ?? "";
    availability = Constant.drGetListParams[ApiParams.availability] ?? "";

    if (availabilityVal.trim().isNotEmpty) {
      availability = Constant.anyDateKey;
    }

    mgender = gender;
    mavailability = availability;
    mavailabilityVal = availabilityVal;
    mspecialityid = specialityid;
    mentity = entity;
  }

  isFilterSet() {
    return (mgender.isNotEmpty ||
        mavailability.isNotEmpty ||
        mspecialityid.isNotEmpty ||
        mentity.isNotEmpty);
  }

  clearFilter() {
    gender = "";
    availability = "";
    specialityid = "";
    availabilityVal = "";
    entity = "";
    setState(() {});
    Navigator.of(context).pop();
    checkFiltercontainsKey(ApiParams.specialityId);
    checkFiltercontainsKey(ApiParams.gender);
    checkFiltercontainsKey(ApiParams.availability);
    checkFiltercontainsKey(ApiParams.entity);
    checkFiltercontainsKey("availabilityVal");

    //Constant.drGetListParams.remove(ApiParams.filter);
    widget.doctorCubit
        .loadPosts(context, Constant.drGetListParams, isSetInitial: true);
  }

  applyFilter() {
    /*filters[ApiParams.gender] = gender;
    filters[ApiParams.availability] = availability;
    filters["availabilityVal"] = availabilityVal;
    if (availability == Constant.anyDateKey) {
      filters[ApiParams.availability] = availabilityVal;
    }
    filters[ApiParams.specialityId] = specialityid;
    filters[ApiParams.entity] = entity;
    Constant.drGetListParams[ApiParams.filter] = json.encode(filters);*/

    Constant.drGetListParams[ApiParams.entity] = entity;
    Constant.drGetListParams[ApiParams.specialityId] = specialityid;
    Constant.drGetListParams[ApiParams.gender] = gender;
    Constant.drGetListParams[ApiParams.availability] = availability;
    Constant.drGetListParams["availabilityVal"] = availabilityVal;
    if (availability == Constant.anyDateKey) {
      Constant.drGetListParams[ApiParams.availability] = availabilityVal;
    }
    widget.doctorCubit
        .loadPosts(context, Constant.drGetListParams, isSetInitial: true);
  }

  checkFiltercontainsKey(String key, {bool isRemove = true}) {
    if (Constant.drGetListParams.containsKey(key)) {
      if (isRemove) Constant.drGetListParams.remove(key);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              getLables(lblFilter),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .apply(color: primaryColor),
            ),
            Spacer(),
            //if (filters.isNotEmpty)
            if (isFilterSet())
              TextButton(
                  onPressed: () {
                    clearFilter();
                  },
                  child: Text(getLables(lblClear),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .apply(color: grey)))
          ]),
          Divider(
            color: lightGrey,
            height: 40,
          ),
          genderWidget(),
          setHeight(),
          entityWidget(),
          setHeight(),
          availabilityWidget(),
          setHeight(),
          specialitywidget(),
          setHeight(),
          if (gender != mgender ||
              availability != mavailability ||
              specialityid != mspecialityid ||
              entity != mentity ||
              availabilityVal != mavailabilityVal)
            GeneralWidgets.btnWidget(context, getLables(lblApply),
                callback: () {
              Navigator.of(context).pop();
              applyFilter();
            })
        ]);
  }

  specialitywidget() {
    return BlocBuilder<SpecialityCubit, SpecialityState>(
      builder: (context, state) {
        if ((state is SpecialityProgress && state.isFirstFetch) ||
            state is SpecialityFailure) {
          return SizedBox.shrink();
        } else if (state is SpecialitySuccess) {
          specialitylist.clear();
          specialitylist.addAll(state.specialityList);

          loadedPage = state.currPage;
        }
        print("state-$state===${specialitylist.length}");
        if (specialitylist.isEmpty) return SizedBox.shrink();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  getLables(lblSpecialties),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .apply(color: grey),
                ),
                Spacer(),
                StreamBuilder(
                    initialData: 0,
                    stream: sc.stream,
                    builder: (context, snapshot) {
                      return AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: snapshot.data < loadedPage - 1 ? 1 : 0,
                        child: IconButton(
                            onPressed: () {
                              if (snapshot.data < loadedPage - 1)
                                pageController.animateToPage(snapshot.data + 1,
                                    duration: Duration(milliseconds: 400),
                                    curve: Curves.easeIn);
                            },
                            icon: Icon(
                              Icons.keyboard_arrow_right,
                            )),
                      );
                    })
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              child: PageView.builder(
                controller: pageController,
                itemCount: loadedPage,
                onPageChanged: (value) {
                  sc.add(value);
                },
                itemBuilder: (context, index) {
                  int offset = index * specialityCurrPageTotal;
                  int lstoffset = offset + specialityCurrPageTotal;
                  if (specialitylist.length < lstoffset) {
                    lstoffset = specialitylist.length;
                  }
                  Iterable<Speciality> splist =
                      specialitylist.getRange(offset, lstoffset);
                  return Wrap(
                      spacing: 10,
                      children: List.generate(
                        splist.length,
                        (index) {
                          Speciality speciality = splist.elementAt(index);

                          return GeneralWidgets.textButtonWidget(
                              specialityid == speciality.id.toString(),
                              speciality.name ?? "",
                              context, () {
                            if (specialityid != speciality.id.toString()) {
                              setState(() {
                                specialityid = speciality.id.toString();
                              });
                            }
                          });
                        },
                      ));
                },
              ),
            ),
          ],
        );
      },
    );
  }

  setHeight() {
    return const SizedBox(height: 15);
  }

  availabilityWidget() {
    return commonWidget(getLables(lblAvailability),
        Constant.filterAvailabilityList, availability,
        otherval: availabilityVal, callback: (String val) {
      availability = val;
      if (val == Constant.anyDateKey) {
        selectDate();
      } else {
        setState(() {
          availabilityVal = "";
        });
      }
    });
  }

  selectDate() async {
    print("dateclick===");
    DateTime? picked = await GeneralMethods.selectDate(context);
    if (picked != null) {
      setState(() {
        availabilityVal = Constant.backendDateFormat.format(picked);
      });
    }
  }

  genderWidget() {
    return commonWidget(getLables(lblGender), Constant.filterGenderList, gender,
        callback: (String val) {
      setState(() {
        gender = val;
      });
    });
  }

  entityWidget() {
    return commonWidget(getLables(lblEntity), Constant.filterEntityList, entity,
        callback: (String val) {
      setState(() {
        entity = val;
      });
    });
  }

  commonWidget(String title, List list, String selectedval,
      {Function? callback, String otherval = ""}) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style:
                    Theme.of(context).textTheme.bodyMedium!.apply(color: grey),
              ),
              if (otherval.trim().isNotEmpty) const SizedBox(width: 8),
              if (otherval.trim().isNotEmpty)
                Expanded(
                  child: Text(
                    "${otherval.split("-").reversed.join("-")}",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: greencolor, fontWeight: FontWeight.w500),
                  ),
                )
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
              spacing: 10,
              children: List.generate(
                  list.length,
                  (index) => GeneralWidgets.textButtonWidget(
                          selectedval == list[index]["key"],
                          list[index]["title"],
                          context, () {
                        if (otherval.trim().isNotEmpty ||
                            (selectedval != list[index]["key"] &&
                                callback != null)) {
                          callback!(list[index]["key"]);
                        }
                      }))),
        ]);
  }
}
