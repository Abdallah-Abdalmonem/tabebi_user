import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tabebi/models/lab.dart';
import '../../app/routes.dart';
import '../../cubits/slotCubit.dart';
import '../../helper/apiParams.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';
import '../../models/slotData.dart';

class SelectLabTimeSlot extends StatefulWidget {
  final Lab? labInfo;
  const SelectLabTimeSlot({Key? key, required this.labInfo}) : super(key: key);

  @override
  SelectLabTimeSlotState createState() => SelectLabTimeSlotState();
}

class SelectLabTimeSlotState extends State<SelectLabTimeSlot> {
  DateTime currentDate = DateTime.now();
  bool isTestVisible = false;
  DateTime? tomorrow;
  DateTime? selectedDate, selectedTime;
  String waitingtime = "";

  final dayFormatter = DateFormat('EEE', Constant.session!.getCurrLangCode());
  final monthFormatter =
      DateFormat('d MMM', Constant.session!.getCurrLangCode());

  @override
  void initState() {
    super.initState();
    setSlotConfigs();
  }

  setSlotConfigs() {
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day,
        Constant.morningSlotStartTime, 0, 0, 0, 0);
    selectedDate = currentDate;
    tomorrow = currentDate.add(Duration(days: 1));
    getSlotInfo();
  }

  getSlotInfo() {
    context.read<SlotCubit>().getSlotList(context, {
      ApiParams.doctorId: widget.labInfo!.id!.toString(),
      ApiParams.type: Constant.appointmentLab,
      ApiParams.date: Constant.backendDateFormat.format(selectedDate!)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(lblSelectTimeSlot), context),
      bottomNavigationBar: bottomBtnWidget(),
      body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: [
            GeneralWidgets.labProfileWidget(
                widget.labInfo!, context, isTestVisible, () {
              setState(() {
                isTestVisible = !isTestVisible;
              });
            }),
            appointmentSlotWidget()
          ]),
    );
  }

  bottomBtnWidget() {
    return BlocBuilder<SlotCubit, SlotState>(
      builder: (context, state) {
        DateTime? seletedSlotDateTime;
        if (selectedDate != null && selectedTime != null) {
          seletedSlotDateTime = DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
              selectedTime!.hour,
              selectedTime!.minute,
              0,
              0,
              0);
        }
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: lightGrey, blurRadius: 25.0, offset: Offset(0, -10))
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (selectedDate != null && selectedTime != null)
              Row(children: [
                Icon(
                  Icons.schedule,
                  color: primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${monthFormatter.format(selectedDate!)}, ${Constant.timeFormatter.format(selectedTime!)}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: primaryColor, fontWeight: FontWeight.w500),
                  ),
                )
              ]),
            const SizedBox(height: 8),
            GeneralWidgets.btnWidget(context, getLables(lblConfirmBooking),
                callback: () {
              if (selectedDate == null) {
                GeneralMethods.showSnackBarMsg(
                    context, getLables(lblSelectDate),
                    bgcolor: black);
                return;
              }
              if (selectedTime == null) {
                GeneralMethods.showSnackBarMsg(
                    context, getLables(lblSelectTime),
                    bgcolor: black);
                return;
              }
              GeneralMethods.goToNextPage(
                  Routes.confirmLabAppointment, context, false,
                  args: {
                    "labInfo": widget.labInfo,
                    "slotDateTime": seletedSlotDateTime,
                    "waitingtime": waitingtime
                  });
            })
          ]),
        );
      },
    );
  }

  appointmentSlotWidget() {
    return GeneralWidgets.cardBoxWidget(
      cpadding: EdgeInsetsDirectional.symmetric(horizontal: 15, vertical: 10),
      childWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          dateSelectionWidget(),
          const SizedBox(height: 30),
          timeSelectionWidget(),
        ],
      ),
    );
  }

  dateSelectionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        headerWidget(getLables(lblSelectDate)),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                DateTime cdate = currentDate.add(Duration(days: index));

                String weekday = cdate == currentDate
                    ? getLables(lblToday)
                    : cdate == tomorrow
                        ? getLables(lblTomorrow)
                        : dayFormatter.format(cdate);
                String title = "$weekday\n${monthFormatter.format(cdate)}";
                return GeneralWidgets.textButtonWidget(
                    selectedDate == cdate, title, context, () {
                  if (selectedDate != cdate) {
                    selectedTime = null;
                    selectedDate = cdate;
                    setState(() {});
                    getSlotInfo();
                  }
                }, tpadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0));
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 10);
              },
              itemCount: Constant.displayNextAppointmentDay),
        ),
      ],
    );
  }

  timeSelectionWidget() {
    return BlocBuilder<SlotCubit, SlotState>(
      builder: (context, state) {
        List<SlotData> slotlist = [];
        if (state is SlotProgress) {
          return Center(child: CircularProgressIndicator());
        } else if (state is SlotFailure) {
          return GeneralWidgets.msgWithTryAgain(state.errorMessage, () {
            getSlotInfo();
          });
        } else if (state is SlotSuccess) {
          slotlist.addAll(state.slotlist!);
          if (state.allslotempty) {
            return GeneralWidgets.msgWithTryAgain(
                getLables(dataNotFoundErrorMessage), () {
              getSlotInfo();
            });
          }
        } else if (state is SlotSelect) {
          slotlist.addAll(state.slotlist!);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            headerWidget(getLables(lblSelectTime)),
            Wrap(
                children: List.generate(slotlist.length, (index) {
              SlotData slot = slotlist[index];
              Map timeinfo = GeneralMethods.getTimeInfo(
                  int.parse(slot.startTime!.split(":").first));
              return slot.allSlot!.isEmpty
                  ? SizedBox.shrink()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          TextButton.icon(
                              onPressed: () {},
                              icon: GeneralWidgets.setSvg(timeinfo["icon"],
                                  width: 20),
                              label: Text(
                                timeinfo["text"],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(color: primaryColor),
                              )),
                          timeSlotWidget(slot, slotlist)
                        ]);
            })),
          ],
        );
      },
    );
  }

  timeSlotWidget(SlotData slotData, List<SlotData> slotlist) {
    List<String> lstdate = slotData.allSlot!;
    return Wrap(
        spacing: 10,
        children: List.generate(lstdate.length, (index) {
          //DateTime cdate = lstdate[index];
          DateTime cdate =
              Constant.timeParserSecond.parse(lstdate[index] + ":00");
          bool isbooked = slotData.bookedSlot!.contains(lstdate[index]);
          return GeneralWidgets.textButtonWidget(selectedTime == cdate,
              Constant.timeFormatter.format(cdate), context, () {
            if (isbooked) {
              return;
            }
            if (selectedTime != cdate) {
              selectedTime = cdate;
              waitingtime = slotData.waitingTime!.toString();
              context.read<SlotCubit>().changeSlotTime(
                  slotlist, selectedDate, selectedTime, waitingtime);
            }
          }, unselectedcolor: isbooked ? redcolor.withOpacity(0.2) : null);
        }));
  }

  headerWidget(String header) {
    return Text(
      header,
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .merge(TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.5)),
    );
  }
}
