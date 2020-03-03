class Observation {
  ObservationState state;
  ObservationCategory observationCategory;
  String code;
  String issued;
  List<Component> components;
}
 enum ObservationState{
    registered,
    preliminary,
    Final,
   amended,
   corrected,
   cancelled,
   entered_in_error,
   unknown
}

enum ObservationCategory{
  social_history,
  vital_signs,
  imaging,
  laboratory,
  procedure,
  survey,
  exam,
  therapy,
  activity,
}

class Component{
  String code;
  dynamic value;
  String unit;
}