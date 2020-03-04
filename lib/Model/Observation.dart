import 'package:enum_to_string/enum_to_string.dart';
String enumToString(value){
  return EnumToString.parse(value);
}
class Observation {
  String state;
  String observationCategory;
  String code;
  String issued;
  List<Component> components;
  static List<Observation> getObservations(data){
    List<Observation> observations = [];
    for(var entry in data){
      if( entry['entry'] == null){
        break;
      }
      for (var resource in entry['entry']){
        observations.add(getObservation(resource['resource']));
      }
    }
    return observations;
  }
  static Observation getObservation(data){
    Observation observation = Observation();
    observation.state = _getObservationState(data['status']);
    print(observation.state);
    if(data['category'] != null) observation.observationCategory = _getObservationCategory(data['category'][0]['coding'][0]['code']);
    observation.code = data['code']['text'];
    observation.issued = data['issued']??"";
    observation.components = _getObservationComponents(data);
    return observation;
  }
  static _getObservationState(String state){
    if(state == null){
      return "";
    }
    switch (state){
      case "registered":
        return "Registered";
      case "preliminary":
        return "Preliminary";
      case "final":
        return "Final";
      case "amended":
        return "Amended";
      case "corrected":
        return "Corrected";
      case "cancelled":
        return "Cancelled";
      case "entered-in-error":
        return "Entered in Error";
      case "unknown":
        return "Unknown";
      default:
        return "";
    }
  }
  static _getObservationCategory(String category){
    if(category == null){
      return "";
    }
    switch (category){
      case "social-history":
        return "Social History";
      case "vital-signs":
        return "Vital Signs";
      case "imaging":
        return "Imaging";
      case "laboratory":
        return "Laboratory";
      case "procedure":
        return "Procedure";
      case "survey":
        return "Survey";
      case "exam":
        return "Exam";
      case "therapy":
        return "Therapy";
      case "activity":
        return "Activity";
      default:
        return "";
    }
  }
  static List<Component> _getObservationComponents(Map<String,dynamic> data){
    var value;
    var unit = "";
    var text;
    List<Component> components = [];
    if(data['valueQuantity'] != null){
      text = data['code']['text'];
      data = data['valueQuantity'];
      value = data['value'];
      unit = data['unit'];
      Component component = Component()
        ..text = text
        ..unit = unit
        ..value = value;
      components.add(component);
    }else if (data['valueCodeableConcept'] != null){
      text = data['code']['text'];
      data = data['valueCodeableConcept'];
      value = data['text'];
      Component component = Component()
      ..text = text
      ..unit = unit
      ..value = value;
      components.add(component);
    }else if(data['component'] != null){
      for(var dataComponent in data['component']){
        Component component = Component();
        component.value = dataComponent['valueQuantity']['value'];
        component.unit = dataComponent['valueQuantity']['unit'];
        component.text = dataComponent['code']['text'];
        components.add(component);
      }
    }
    return components;
  }
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

class Component {
  String text;
  dynamic value;
  String unit;
}