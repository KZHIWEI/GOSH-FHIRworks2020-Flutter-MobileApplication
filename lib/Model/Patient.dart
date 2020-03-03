import 'package:enum_to_string/enum_to_string.dart';
String enumToString(value){
  return EnumToString.parse(value);
}
class Patient {
  List<Identifier> identifiers;
  List<HumanName> names;
  List<Address> addresses;
  List<ContactPoint> telecom;
  Gender gender;
  DateTime birthDate;
  String maritalStatus;
  int multipleBirth;
  String id;
  List<String> communications;
  static Patient getPatient(data){
    Patient patient = new Patient();
    patient.identifiers = Identifier.getIdentifiers(data['identifier']);
    for (Identifier identifier in patient.identifiers){
      if(identifier.identifierType == IdentifierType.ID){
        patient.id = identifier.value;
        break;
      }
    }
    patient.names = HumanName.getNames(data['name']);
    patient.telecom = ContactPoint.getContactPoints(data['telecom']);
    for (Gender gender in Gender.values){
      if(data['gender']== enumToString(gender)){
        patient.gender = gender;
        break;
      }
    }
    patient.birthDate = DateTime.parse(data['birthDate']);
    patient.maritalStatus = getMaritalStatus(data['maritalStatus']['text']);
    patient.addresses =Address.getAddresses(data['address']);
    patient.communications = [];
    for(var communication in data['communication']){
      patient.communications.add(communication['language']['text']);
    }
    return patient;
  }
}
enum Gender{
  male,female , other ,unknown
}
enum NameUse {
  usual,
  official,
  temp,
  nickname,
  anonymous,
  old,
  maiden,
}

class HumanName {
  NameUse use;
  String text;
  String family;
  List<String> given;
  List<String> prefix;
  List<String> suffix;
  String period;
  static List<HumanName> getNames(data){
    List<HumanName> names = [];
    for (Map<String,dynamic> nameMap in data){
      HumanName humanName = HumanName();
      for (NameUse nameUse in NameUse.values){
        if(nameMap['use']== enumToString(nameUse)){
          humanName.use = nameUse;
          break;
        }
      }
      humanName.family = nameMap['family'];
      humanName.given = [];
      humanName.prefix = [];
      humanName.suffix = [];
      for(String given in nameMap['given']??[]){
        humanName.given.add(given);
      }
      for(String prefix in nameMap['prefix']??[]){
        humanName.prefix.add(prefix);
      }
      for(String suffix in nameMap['suffix']??[]){
        humanName.suffix.add(suffix);
      }
      names.add(humanName);
    }
    return names;
  }
}

enum IdentifierType {
  ID,
  DL, //	Driver's license number
  PPN, //	Passport number
  BRN, //	Breed Registry Number
  MR, //	Medical record number
  MCN, //	Microchip Number
  EN, //	Employer number
  TAX, //	Tax ID number
  NIIP, //	National Insurance Payor Identifier (Payor)
  PRN, //	Provider number
  MD, //	Medical License number
  DR, //	Donor Registration Number
  ACSN, //	Accession ID
  UDI, //	Universal Device Identifier
  SNO, //	Serial Number
  SB, //	Social Beneficiary Identifier
  PLAC, //	Placer Identifier
  FILL, //Filler Identifier
  JHN //Jurisdictional health number (Canada)
}

class Identifier {
  String use;
  IdentifierType identifierType;
  String system;
  String value;
  static List<Identifier> getIdentifiers(data){
    List<Identifier> identifiers = <Identifier>[];
    for(Map<String,dynamic> identifierMap in data){
      Identifier identifier = Identifier();
      if(!identifierMap.containsKey('type')){
        identifier.identifierType = IdentifierType.ID;
        identifier.value = identifierMap['value'];
      }else{
        for (IdentifierType idType in IdentifierType.values){
          if(identifierMap['type']['coding'][0]['code'] == enumToString(idType)){
            identifier.identifierType = idType;
            identifier.value = identifierMap['value'];
            break;
          }
        }
      }
      identifiers.add(identifier);
    }
    return identifiers;
  }
}

enum AddressUse { home, work, temp, old, billing }

enum AddressType {postal,physical,both}

class Address {
  AddressUse use;
  AddressType type;
  String text;
  List<String> lines;
  String city;
  String district;
  String state;
  String postalCode;
  String country;
  static List<Address> getAddresses(data){
    List<Address> addresses = <Address>[];
    for(Map<String,dynamic> addressMap in data){
      Address address = Address();
      address.lines = [];
      for(String line in addressMap['line']??[]){
        address.lines.add(line);
      }
      address.city = addressMap['city'];
      address.state = addressMap['state'];
      address.postalCode = addressMap['postalCode'];
      address.country = addressMap['country'];
      address.district = addressMap['district'];
      addresses.add(address);
    }
    return addresses;
  }
  @override
  String toString() {
    String line = "";
    this.lines.forEach((element) {
      line += "$element ";
    });
    return '$line,${this.city},${this.state},${this.country} ${this.postalCode??""}';
  }
}
enum ContactSystem{
  phone, fax, email, pager, url, sms, other
}
enum ContactUse{
  home, work, temp, old, mobile
}
class ContactPoint {
  ContactSystem system;
  String value;
  ContactUse use;
  int rank;
  static List<ContactPoint> getContactPoints(data){
    List<ContactPoint> contactPoints = <ContactPoint>[];
    for(Map<String,dynamic> contactPointMap in data){
      ContactPoint contactPoint = ContactPoint();
      for (ContactSystem contactSystem in ContactSystem.values){
        if(contactPointMap['system']== enumToString(contactSystem)){
          contactPoint.system = contactSystem;
          break;
        }
      }
      contactPoint.value = contactPointMap['value'];
      for (ContactUse contactUse in ContactUse.values){
        if(contactPointMap['use']== enumToString(contactUse)){
          contactPoint.use = contactUse;
          break;
        }
      }
      contactPoints.add(contactPoint);
    }
    return contactPoints;
  }
}

enum MaritalStatus{
  A, //	Marriage contract has been declared null and to not have existed
  D, //	Marriage contract has been declared dissolved and inactive
  I, //	Subject to an Interlocutory Decree.
  L,	// Legally Separated\
  M, //	A current marriage contract is active
  P, //	More than 1 current spouse
  S, //	No marriage contract has ever been entered
  T, //	Person declares that a domestic partner relationship exists.
  U, //	Currently not in a marriage contract.
  W, //	The spouse has died
  UNK
}

String getMaritalStatus(data){
  switch (data){
    case "A":
      return "Annulled";
    case "D":
      return "Divorced";
    case "I":
      return "Interlocutory";
    case "L":
      return "Legally Separated";
    case "M":
      return "Married";
    case "P":
      return "Polygamous";
    case "S":
      return "Never Married";
    case "T":
      return "Domestic partner";
    case "U":
      return "unmarried";
    case "W":
      return "Widowed";
    case "UNK":
      return "unknown";
    default:
      return "";
  }
}

class Communication{
  String language;
  bool preferred;
}
