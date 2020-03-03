class Patient {
  List<Identifier> identifier;
  List<HumanName> names;
  List<Address> addresses;
  List<ContactPoint> telecom;
  Gender gender;
  DateTime birthDate;
  MaritalStatus maritalStatus;
  int multipleBirth;
  List<Communication> communications;
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
}

enum IdentifierType {
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

}

enum MaritalStatus{
  Annulled, //	Marriage contract has been declared null and to not have existed
  Divorced, //	Marriage contract has been declared dissolved and inactive
  Interlocutory, //	Subject to an Interlocutory Decree.
  Legally_Separated,	// Legally Separated\
  Married, //	A current marriage contract is active
  Polygamous, //	More than 1 current spouse
  Never_Married, //	No marriage contract has ever been entered
  Domestic_partner, //	Person declares that a domestic partner relationship exists.
  unmarried, //	Currently not in a marriage contract.
  Widowed, //	The spouse has died
  unknown
}

class Communication{
  String language;
  bool preferred;
}
