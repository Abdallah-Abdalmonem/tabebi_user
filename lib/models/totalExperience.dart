class TotalExperience {
  int? y;
  int? m;
  int? d;
  int? h;
  int? i;
  int? s;
  int? f;
  int? weekday;
  int? weekdayBehavior;
  int? firstLastDayOf;
  int? invert;
  int? days;
  int? specialType;
  int? specialAmount;
  int? haveWeekdayRelative;
  int? haveSpecialRelative;

  TotalExperience(
      {this.y,
      this.m,
      this.d,
      this.h,
      this.i,
      this.s,
      this.f,
      this.weekday,
      this.weekdayBehavior,
      this.firstLastDayOf,
      this.invert,
      this.days,
      this.specialType,
      this.specialAmount,
      this.haveWeekdayRelative,
      this.haveSpecialRelative});

  TotalExperience.fromJson(Map<String, dynamic> json) {
    y = json['y'];
    m = json['m'];
    d = json['d'];
    h = json['h'];
    i = json['i'];
    s = json['s'];
    f = json['f'];
    weekday = json['weekday'];
    weekdayBehavior = json['weekday_behavior'];
    firstLastDayOf = json['first_last_day_of'];
    invert = json['invert'];
    days = json['days'];
    specialType = json['special_type'];
    specialAmount = json['special_amount'];
    haveWeekdayRelative = json['have_weekday_relative'];
    haveSpecialRelative = json['have_special_relative'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['y'] = this.y;
    data['m'] = this.m;
    data['d'] = this.d;
    data['h'] = this.h;
    data['i'] = this.i;
    data['s'] = this.s;
    data['f'] = this.f;
    data['weekday'] = this.weekday;
    data['weekday_behavior'] = this.weekdayBehavior;
    data['first_last_day_of'] = this.firstLastDayOf;
    data['invert'] = this.invert;
    data['days'] = this.days;
    data['special_type'] = this.specialType;
    data['special_amount'] = this.specialAmount;
    data['have_weekday_relative'] = this.haveWeekdayRelative;
    data['have_special_relative'] = this.haveSpecialRelative;
    return data;
  }
}
