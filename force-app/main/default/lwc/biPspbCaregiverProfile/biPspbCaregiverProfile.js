// The lightning component is designed to retrieve and update caregiver details from the account object
// To import Libraries
import { LightningElement, wire, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
// To import Apex Classes
import USER_CAREGIVER from "@salesforce/apex/BI_PSPB_ProfileManagerCtrl.userCaregiver";
import GET_EXISTING_ACCOUNTS from "@salesforce/apex/BI_PSPB_EnrollmentUtilities.getExistingAccounts";
import USER_CAREGIVERS from "@salesforce/apex/BI_PSP_CurrentUser.getEnrolleeRecords";
import UPDATE_CAREGIVER_DETAILS from "@salesforce/apex/BI_PSPB_ProfileManagerCtrl.updateCaregiverDetails";
import GET_RELATIONSHIP from "@salesforce/apex/BI_PSPB_ProfileManagerCtrl.getCurrentEnrolleCaregiver";
import * as label from "c/biPspbLabelAndResourceSymptom";

// To get Current UserId
import ID from "@salesforce/user/Id";

import { resources } from "c/biPspbResourceProfileManager";

export default class BiPspbCaregiverProfile extends LightningElement {
  // Track variable Declarations(re-render variables)
  updatePopup = false;
  defaultImg = "";
  validateform = false;
  matchEmail = false;
  @track placeholderClass = 'date-input-container';
  @track preffer = [
    { label: resources.SMS_LABEL, value: resources.SMS_LABEL },
    { label: resources.PHONE_LABEL, value: resources.PHONE_LABEL },
    { label: resources.EMAIL_LABEL, value: resources.EMAIL_LABEL }
  ];
  errorMessage = "";
  firstNameErrorMessageValid = false;
  lastNameErrorMessageValid = false;
  minorerror = false;
  accname;
  emailErrorMessage = false;
  phoneErrorMessage = false;
  pcmErrorMessage = false;
  relationshipErrorMessage = false;
  FirstNameErrorMessage = false;
  dobErrorMessage = false;
  showContactNumber = false;
  lastNameErrorMessage = false;
  firstName;
  lastName;
  birthDate;
  relationshipVal;
  personEmailVal;
  minorErrorYear;
  existEmail = resources.EXIST_EMAIL;
  minorErrorFutureDate;
  phoneRecord;
  error = false;
  dateOfBirth;
  age;
  selectedAvatarSrc;
  futureError = false;
  majorError = false;
  communicationMode;
  phoneNumberMandatory = false;
  phoneVisbleField = true;
  pmc = resources.PHONE_NUMBER_LABEL;
  phoneNumberVisible = true;
  pmcRequire = false;
  boxedIcon = label.BOXED_ICON;
  accountIdVal;
  @track leadPmc = [
    { label: resources.PARENT_STRING, value: resources.PARENT_STRING },
    { label: resources.SIBLING_STRING, value: resources.SIBLING_STRING },
    { label: resources.LOVED_ONE, value: resources.LOVED_ONE },
    { label: resources.GUARDIAN, value: resources.GUARDIAN },
    { label: resources.FRIEND, value: resources.FRIEND },
    { label: resources.OTHER_RELATIVE, value: resources.OTHER_RELATIVE }
  ];
  //Global variables(without does not trigger automatic re-renders)
  rightImg = resources.RIGHT_ICON;
  warningIcon = resources.WARNING_IMAGE;
  ticIcon = resources.TIC_IMAGE;
  firstNameError = resources.FIRST_NAME;
  futuredateError = resources.FUTHURE_DATE;
  majorDateError = resources.ABOVE_ERROR;
  lastNameError = resources.LAST_NAME;
  phoneFieldError = resources.PHONE_ERROR;
  preferredMode = resources.PREFERRED_CONTACT_METHOD;
  dobError = resources.MINOR_ERROR;
  relationshipError = resources.RELATIONSHIP;
  emailError = resources.EMAIL;
  profileUpdate = resources.PROFILE_UPDATE;
  warning = resources.WARNING;
  enterPreferredMode = resources.ENTER_PREFERRED;
  myProfile = resources.MYPROFILE;
  personalInformation = resources.PERSONAL_INFORMATION;
  validFirstname = resources.VALIDFNAME;
  validLastname = resources.VALIDLNAME;
  dateError = resources.DOB;
  enterDob = resources.ENTER_DOB;
  enterLastName = resources.ENTER_LASTNAME;
  enterFirstName = resources.ENTER_FIRSTNAME;
  enterEmail = resources.ENTER_EMAIL;
  select = resources.SELECT;
  enterPhone = resources.PHONE_NUMBER;
  communicationDetails = resources.COMMUNICATION_DETAILS;
  saveChanges = resources.SAVECHANGES;
  prefferedLabel = resources.PREFFERED_LABEL;
  emailLabel = resources.EMAIL_HEADING;
  dobLabel = resources.DOB_LABEL;
  firstnamelabel = resources.FIRSTNAME_LABEL;
  lastnameLabel = resources.LASTNAME_LABEL;
  userId = ID;
  informationgender = resources.INFORMATIONGENDER;
  informationgenderboth = resources.EMAILMSGBOTH;
  informationgendermsg = resources.EMAILlMSG;
  cgpatientconfirmchange = resources.CONFIRMCHANGES;
  cgpatientconfirmseven = resources.CONFIRSEVEN;
  cgpatientconfirmup = resources.CONFIRMUP;
  cgpatientconfirmupNew = resources.CONFIRMUPNEW;
  cgpatientconfirmtext = resources.CONFIRMTEXT;
  cgpatientconfirm = resources.CONFIRM;
  caregiverMSg = resources.CGMSGONE
  caregiver = resources.CGMSG

  yesLabel = label.YES;
  noLabel = label.NO;
  name;
  emailModifiedDate;
  isEmailDisabled = false;
  differenceInDays;
  /*There's no need to check for null because in Apex, we're throwing an AuraHandledException. 
  Therefore, null data won't be encountered.*/
  // To reterive the caregiver account details
  @wire(USER_CAREGIVER)
  wiredUserCaregiver({ error, data }) {
    try {
      this.placeholderClass = 'hide-placeholder';
      if (data && data.length > 0) {
        this.accname = data;
        this.accountIdVal = data[0]?.Id;
        this.firstName = data[0]?.FirstName;
        this.lastName = data[0]?.LastName;
        this.name = data[0]?.FirstName + " " + data[0]?.LastName;
        this.birthDate = data[0]?.BI_PSP_Birthdate__c;
        this.personEmailVal = data[0]?.PersonEmail;
        this.patientEmailold = data[0]?.PersonEmail;
        this.phoneRecord = data[0]?.Phone;

        this.communicationMode =
          data[0]?.BI_PSPB_Preferred_Communication_Method__c;
        if (this.communicationMode === null || this.communicationMode === undefined) {
          this.communicationMode = resources.EMAIL_LABEL;
        }
        if (data[0].BI_PSP_EmailModifiedDate__c === null || data[0].BI_PSP_EmailModifiedDate__c === undefined) {
          this.isEmailDisabled = false;

        } else {
          this.emailModifiedDate = data[0].BI_PSP_EmailModifiedDate__c;
          this.differenceInDays = this.dateDifference();
          this.isEmailDisabled = this.differenceInDays < resources.EmailModified;
        }
        if (typeof this.phoneRecord === resources.UNDEFINED_VALUE) {
          this.phoneRecord = "";
        }
        if (typeof window !== "undefined") {
          this.dispatchEvent(new CustomEvent("load"));
        }
        if (
          this.communicationMode === resources.SMS_LABEL ||
          this.communicationMode === resources.PHONE_LABEL
        ) {
          this.phoneNumberMandatory = true;
          this.phoneNumberVisible = false;
          this.pmc = resources.PHONE_MANDATORY;
        }
      } else if (error) {
        this.error = resources.CAREGIVER_NOT_FOUND;
        this.navigateToErrorPage(error.body.message);
      }
    } catch (err) {
      this.error = resources.CAREGIVER_NOT_FOUND;
      this.navigateToErrorPage(err.message);
    }
  }

  @wire(GET_RELATIONSHIP)
  wiredCaregiverRelation({ error, data }) {
    try {
      if (data) {
        this.relationshipVal = data.BI_PSPB_Relationship_to_Patient__c;
      } else if (error) {
        this.navigateToErrorPage(error.body.message);
      }
    } catch (err) {
      this.navigateToErrorPage(err.message);
    }
  }
  dateDifference() {
    if (this.emailModifiedDate) {
      // Convert the BI_PSP_EmailModifiedDate__c to a Date object
      const emailModified = new Date(this.emailModifiedDate);
      const today = new Date();

      // Ensure that emailModified is a valid date
      if (isNaN(emailModified.getTime())) {
        return null;
      }

      // Calculate the difference in milliseconds
      const differenceInTime = today.getTime() - emailModified.getTime();

      // Convert milliseconds to days
      const differenceInDays = Math.floor(
        differenceInTime / (1000 * 3600 * 24)
      );
      return differenceInDays;
    }
    return null;
  }
  // To close popup and reload the page
  handleClose() {
    this.updatePopup = false;
  }

  // To validate the date of birth
  validateDate() {
    // Validate that the date is not in the future
    let currentDate = new Date();
    let selectedDate = new Date(this.patientDOB);
    this.placeholderClass = 'hide-placeholder';

    if (selectedDate > currentDate) {
      this.minorErrorFutureDate = true;
      this.minorErrorYear = false;
      this.dobErrorMessage = false;
      this.minorerror = false;
      this.template.querySelector(
        'lightning-combobox[data-field="Birthdate"]'
      ).className = "dateText-err";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-error-label";

      return;
    }
    this.minorErrorFutureDate = false;
    this.template.querySelector(
      'lightning-combobox[data-field="Birthdate"]'
    ).className = "dateText";
    this.template.querySelector('label[data-field="Birthdate"]').className =
      "input-label";

    // Validate that the user is not a minor (you can set a minimum age)
    let minAge = resources.MINOR_AGE;
    let userBirthYear = selectedDate.getFullYear();
    let currentYear = currentDate.getFullYear();

    if (currentYear - userBirthYear < minAge) {
      this.dobErrorMessage = false;
      this.minorerror = true;
      this.minorErrorFutureDate = false;
      this.minorErrorYear = false;
      this.dobErrorMessage = false;
      this.template.querySelector(
        'lightning-combobox[data-field="Birthdate"]'
      ).className = "dateText-err";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-error-label";
      return;
    }
    this.dobErrorMessage = false;
    this.minorerror = false;
    this.minorErrorYear = false;
    this.minorErrorFutureDate = false;
    this.template.querySelector(
      'lightning-combobox[data-field="Birthdate"]'
    ).className = "dateText-err";
    this.template.querySelector('label[data-field="Birthdate"]').className =
      "input-error-label";

    //get full year
    if (selectedDate < new Date("1900-01-01")) {
      this.minorErrorYear = true;
      this.minorErrorFutureDate = false;
      this.dobErrorMessage = false;
      this.minorerror = false;
      this.template.querySelector(
        'lightning-combobox[data-field="Birthdate"]'
      ).className = "dateText-err";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-error-label";

      return;
    }
    this.minorErrorYear = false;
    this.minorErrorFutureDate = false;
    this.dobErrorMessage = false;
    this.minorerror = false;
    this.template.querySelector(
      'lightning-combobox[data-field="Birthdate"]'
    ).className = "dateText";
    this.template.querySelector('label[data-field="Birthdate"]').className =
      "input-label";

    // If both validations pass, clear the error message

    this.dobErrorMessage = "";
  }

  // To validate the Birth date
  validateBirthdate() {
    let birthdateField = this.template.querySelector(
      'input[data-field="Birthdate"]'
    );

    if (!birthdateField.value) {
      this.dobErrorMessage = true;
      // Add CSS classes to highlight the input field and label with an error

      this.template.querySelector(
        'input[data-field="Birthdate"]'
      ).className = "dateText-err";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-error-label";
    } else {
      this.dobErrorMessage = false;
      this.template.querySelector(
        'input[data-field="Birthdate"]'
      ).className = "dateText";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-label";
    }
    this.handleFinalData();
  }

  // To validate the First Name
  validateFirstName() {
    if (!this.firstName) {
      this.firstNameErrorMessage = true;
      this.firstNameErrorMessageValid = false;
      // Add CSS classes to highlight the input field and label with an error
      this.template
      
        .querySelector('lightning-input[data-field="FirstName"]')
        .classList.add("textInput-err");
      this.template
        .querySelector('label[data-field="FirstName"]')
        .classList.add("input-error-label");
    } else if (!/^[a-zA-ZÀ-ž\s\-'.`]+$/u.test(this.firstName)) {
      this.firstNameErrorMessage = false;
      this.firstNameErrorMessageValid = true;
      this.template
        .querySelector('lightning-input[data-field="FirstName"]')
        .classList.add("textInput-err");
      this.template
        .querySelector('label[data-field="FirstName"]')
        .classList.add("input-error-label");
    } else {
      this.firstNameErrorMessage = false;
      this.firstNameErrorMessageValid = false;
      this.template
        .querySelector('lightning-input[data-field="FirstName"]')
        .classList.add("textInput");
      this.template
        .querySelector('label[data-field="FirstName"]')
        .classList.add("input-label");
    }
  }

  // To validate the Last Name
  validateLastName() {
    if (!this.lastName) {
      this.lastNameErrorMessage = true;
      this.lastNameErrorMessageValid = false;
      // Add CSS classes to highlight the input field and label with an error
      this.template
        .querySelector('lightning-input[data-field="LastName"]')
        .classList.add("textInput-err");
      this.template
        .querySelector('label[data-field="LastName"]')
        .classList.add("input-error-label");
    } else if (!/^[a-zA-ZÀ-ž\s\-'.`]+$/u.test(this.lastName)) {
      this.lastNameErrorMessage = false;
      this.lastNameErrorMessageValid = true;
      this.template
        .querySelector('lightning-input[data-field="LastName"]')
        .classList.add("textInput-err");
      this.template
        .querySelector('label[data-field="LastName"]')
        .classList.add("input-error-label");
    } else {
      this.lastNameErrorMessage = false;
      this.lastNameErrorMessageValid = false;
    }
  }

  // All the event function to capture the event record
  handleNameChange(event) {
    this.changeName = true;
    this.firstName = event.target.value;
    this.firstName =
      event.target.value.trim().charAt(0).toUpperCase() +
      event.target.value.trim().slice(1);
    this.validateFirstName();
    this.patientValidateForm();
  }

  handleLastNameChange(event) {
    this.changeName = true;
    this.lastName = event.target.value;
    this.lastName =
      event.target.value.trim().charAt(0).toUpperCase() +
      event.target.value.trim().slice(1);
    this.validateLastName();
    this.patientValidateForm();
  }
  changeBirthData(event) {
    this.birthDate = event.target.value;
  }

  relationshipEvent(event) {
    this.changeName = true;
    this.relationshipVal = event.target.value;
  }

  validatePhoneChange() {
    this.changeName = true;
    if (
      this.communicationMode === resources.SMS_LABEL ||
      this.communicationMode === resources.PHONE_LABEL
    ) {
      if (
        !this.phoneRecord ||
        this.phoneRecord === "" ||
        this.phoneRecord.length === 0
      ) {
        this.phoneErrorMessage = true;
        this.template.querySelector(
          'lightning-input[data-field="MobilePhone"]'
        ).className = "textInput-err";
        this.template.querySelector(
          'label[data-field="MobilePhone"]'
        ).className = "input-error-label";
        this.template
          .querySelector('lightning-input[data-field="MobilePhone"]')
          .classList.add("textInput-err");
        this.template
          .querySelector('label[data-field="MobilePhone"]')
          .classList.add("input-error-label");
      } else {
        this.template
          .querySelector('lightning-input[data-field="MobilePhone"]')
          .classList.remove("textInput-err");
        this.template
          .querySelector('label[data-field="MobilePhone"]')
          .classList.remove("input-error-label");
        this.phoneErrorMessage = false;
      }
    } else {
      this.template
        .querySelector('lightning-input[data-field="MobilePhone"]')
        .classList.remove("textInput-err");
      this.template
        .querySelector('label[data-field="MobilePhone"]')
        .classList.remove("input-error-label");
      this.template.querySelector(
        'lightning-input[data-field="MobilePhone"]'
      ).className = "textInput";
      this.template.querySelector('label[data-field="MobilePhone"]').className =
        "input-label";
      this.phoneErrorMessage = false;
    }
  }

  phoneChangeEvent(event) {
    this.changeName = true;
    this.phoneRecord = event.target.value;

    if (
      this.communicationMode === resources.SMS_LABEL ||
      this.communicationMode === resources.PHONE_LABEL
    ) {
      if (
        !this.phoneRecord ||
        this.phoneRecord === "" ||
        this.phoneRecord.length === 0
      ) {
        this.phoneErrorMessage = true;
        this.template.querySelector(
          'lightning-input[data-field="MobilePhone"]'
        ).className = "textInput-err";
        this.template.querySelector(
          'label[data-field="MobilePhone"]'
        ).className = "input-error-label";
      } else {
        this.template
          .querySelector('lightning-input[data-field="MobilePhone"]')
          .classList.remove("textInput-err");
        this.template
          .querySelector('label[data-field="MobilePhone"]')
          .classList.remove("input-error-label");
        this.template.querySelector(
          'lightning-input[data-field="MobilePhone"]'
        ).className = "textInput";
        this.template.querySelector(
          'label[data-field="MobilePhone"]'
        ).className = "input-label";
        this.phoneErrorMessage = false;
      }
    }
  }

  // Validate and update input values
  patientValidateForm() {
    
    let isValid = true;

    let emailField = this.template.querySelector(
      'lightning-input[data-field="email"]'
    );
    if (!emailField.value) {
      this.emailErrorMessage = true;
      isValid = false;
      emailField.className = "textInput-err";
      this.template.querySelector('label[data-field="email"]').className =
        "input-error-label";
    } else {
      this.emailErrorMessage = false;

      emailField.className = "textInput";
      this.template.querySelector('label[data-field="email"]').className =
        "input-label";
    }

    let FirstNameField = this.template.querySelector(
      'lightning-input[data-field="FirstName"]'
    );
    if (!FirstNameField.value) {
      this.FirstNameErrorMessage = true;
      this.firstNameErrorMessageValid = false;
      isValid = false;
      FirstNameField.className = "textInput-err";
      this.template.querySelector('label[data-field="FirstName"]').className =
        "input-error-label";
    } else if (!/^[a-zA-ZÀ-ž\s\-'.`]+$/u.test(this.firstName)) {
      this.firstNameErrorMessage = false;
      this.firstNameErrorMessageValid = true;
      FirstNameField.className = "textInput-err";
      this.template.querySelector('label[data-field="FirstName"]').className =
        "input-error-label";
    } else {
      this.FirstNameErrorMessage = false;
      this.firstNameErrorMessageValid = false;
      FirstNameField.className = "textInput";
      this.template.querySelector('label[data-field="FirstName"]').className =
        "input-label";
    }
    let lastnameField = this.template.querySelector(
      'lightning-input[data-field="LastName"]'
    );
    if (!lastnameField.value) {
      this.lastNameErrorMessage = true;
      this.lastNameErrorMessageValid = false;
      isValid = false;
      lastnameField.className = "textInput-err";
      this.template.querySelector('label[data-field="LastName"]').className =
        "input-error-label";
    } else if (!/^[a-zA-ZÀ-ž\s\-'.`]+$/u.test(this.lastName)) {
      this.lastNameErrorMessage = false;
      this.lastNameErrorMessageValid = true;
      lastnameField.className = "textInput-err";
      this.template.querySelector('label[data-field="LastName"]').className =
        "input-error-label";
    } else {
      this.lastNameErrorMessage = false;
      this.lastNameErrorMessageValid = false;
      lastnameField.className = "textInput";
      this.template.querySelector('label[data-field="LastName"]').className =
        "input-label";
    }
    let relationshipField = this.template.querySelector(
      'lightning-input[data-field="Relationship"]'
    );
    if (!relationshipField.value) {
      this.relationshipErrorMessage = true;

      isValid = false;
      relationshipField.className = "textInput-err";
      this.template.querySelector(
        'label[data-field="Relationship"]'
      ).className = "input-error-label";
    } else {
      this.relationshipErrorMessage = false;

      relationshipField.className = "textInput";
      this.template.querySelector(
        'label[data-field="Relationship"]'
      ).className = "input-label";
    }

    let BirthdateField = this.template.querySelector(
      'lightning-input[data-field="Birthdate"]'
    );
    let Phonefield = this.template.querySelector(
      'lightning-input[data-field="MobilePhone"]'
    );
    let Preferredmodefield = this.template.querySelector(
      'lightning-input[data-field="PreferredMethodofCommunication"]'
    );

    if (BirthdateField.value) {
      this.phoneErrorMessage = true;
      Phonefield.className = "textInput-err";
      this.template.querySelector('label[data-field="MobilePhone"]').className =
        "input-error-label";
      if (Phonefield.value) {
        this.phoneErrorMessage = false;
        Phonefield.className = "textInput";
        this.template.querySelector(
          'label[data-field="MobilePhone"]'
        ).className = "input-label";
      }
      this.pcmErrorMessage = true;
      Preferredmodefield.className = "textInput-err";
      this.template.querySelector(
        'label[data-field="PreferredMethodofCommunication"]'
      ).className = "input-error-label";
      if (Preferredmodefield.value) {
        this.pcmErrorMessage = false;
        Preferredmodefield.className = "textInput";
        this.template.querySelector(
          'label[data-field="PreferredMethodofCommunication"]'
        ).className = "input-label";
      }
      let dobDate = this.birthDate;
      let today = new Date();
      let age = today.getFullYear() - dobDate.getFullYear();
      if (age <= resources.MINOR_AGE) {
        this.minorerror = true;
        this.futureError = false;
        this.majorError = false;
        this.dobErrorMessage = false;

        isValid = false;
        BirthdateField.className = "dateText-err";
        this.template.querySelector('label[data-field="Birthdate"]').className =
          "input-error-label";
      } else {
        isValid = false;
        this.minorerror = false;
        this.futureError = false;
        this.majorError = false;
        this.dobErrorMessage = false;
        BirthdateField.className = "dateText";
        this.template.querySelector('label[data-field="Birthdate"]').className =
          "input-label";
      }
    } else {
      this.dobErrorMessage = true;
      this.phoneErrorMessage = false;
      BirthdateField.className = "dateText-err";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-error-label";
    }

    if (!Phonefield.value) {
      this.phoneErrorMessage = true;
      isValid = false;
      Phonefield.className = "textInput-err";
      this.template.querySelector('label[data-field="MobilePhone"]').className =
        "input-error-label";
    } else {
      this.phoneErrorMessage = false;

      Phonefield.className = "textInput";
      this.template.querySelector('label[data-field="MobilePhone"]').className =
        "input-label";
    }

    if (!Preferredmodefield.value) {
      this.pcmErrorMessage = true;
      isValid = false;
      Preferredmodefield.className = "textInput-err";
      this.template.querySelector(
        'label[data-field="PreferredMethodofCommunication"]'
      ).className = "input-error-label";
    } else {
      this.pcmErrorMessage = false;
      Preferredmodefield.className = "textInput";
      this.template.querySelector(
        'label[data-field="PreferredMethodofCommunication"]'
      ).className = "input-label";
    }
    return isValid;
  }

  // Initialize to false

  ageCalculationEvent(event) {
    this.birthDate = event.target.value;
    if (!this.birthDate || this.birthDate === null || this.birthDate === "") {
      this.dobErrorMessage = true;
      this.minorerror = false;
      this.futureError = false;
      this.majorError = false;
      this.template.querySelector(
        'input[data-field="Birthdate"]'
      ).className = "dateText-err";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-error-label";
      return;
    }
    let dobDate = new Date(event.target.value);
    let today = new Date();
    let age = today.getFullYear() - dobDate.getFullYear();
    let BirthdateField = this.template.querySelector(
      'input[data-field="Birthdate"]'
    );

    if (age <= resources.MINOR_AGE) {
      BirthdateField.className = "dateText-err";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-error-label";
      this.minorerror = true;
      this.futureError = false;
      this.majorError = false;
      this.dobErrorMessage = false;
    } else {
      this.minorerror = false;
      this.futureError = false;
      this.majorError = false;
      this.dobErrorMessage = false;
      BirthdateField.className = "dateText";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-label";
    }
    if (dobDate > today) {
      this.futureError = true;
      this.minorerror = false;
      this.majorError = false;
      this.dobErrorMessage = false;
    }
    if (dobDate.getFullYear() < 1900) {
      BirthdateField.className = "dateText-err";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-error-label";
      this.majorError = true;
      this.futureError = false;
      this.minorerror = false;
      this.dobErrorMessage = false;
    }
    if (age >= resources.MINOR_AGE && age <= 100) {
      this.majorError = false;
      this.futureError = false;
      this.minorerror = false;
      this.dobErrorMessage = false;
    }

    // Check if the selected date is in the future
    if (dobDate > today) {
      // Display the validation message
      let errorMessage = resources.MINOR_ERROR;
      this.template.querySelector('[data-field="dob-error"]').textContent =
        errorMessage;

      // Clear the input field or take other appropriate actions as needed
      event.target.value = "";

      // You can also prevent the form from submitting if needed
      event.preventDefault();
    } else {
      // Clear the validation message if the date is valid
      this.template.querySelector('[data-field="dob-error"]').textContent = "";
    }
  }

  handleCommunicationMethodChange(event) {
    this.communicationMode = event.target.value;
    this.pmcRequire = false;
    if (this.communicationMode === resources.EMAIL_LABEL) {
      this.emailMandatory = true;
      this.phoneNumberVisible = true;
      this.phoneNumberMandatory = false;
      this.phoneErrorMessage = false;
      this.template.querySelector(
        'lightning-input[data-field="MobilePhone"]'
      ).className = "textInput";
      this.template.querySelector('label[data-field="MobilePhone"]').className =
        "input-label";
      this.pmc = resources.PHONE_NUMBER_LABEL;
    } else {
      this.phoneNumberMandatory = false;
      this.phoneNumberVisible = true;
      if (this.phoneRecord === "" || this.phoneRecord.length <= 0) {
        this.phoneErrorMessage = true;
        this.template.querySelector(
          'lightning-input[data-field="MobilePhone"]'
        ).className = "textInput-err";
        this.template.querySelector(
          'label[data-field="MobilePhone"]'
        ).className = "input-error-label";
      } else {
        this.phoneErrorMessage = false;
      }
    }
    if (
      this.communicationMode === resources.SMS_LABEL ||
      this.communicationMode === resources.PHONE_LABEL
    ) {
      this.phoneNumberMandatory = true;
      this.phoneNumberVisible = false;
      this.pmc = resources.PHONE_MANDATORY;
    } else {
      this.phoneNumberMandatory = false;
      this.phoneNumberVisible = true;
    }
    if (this.communicationMode === resources.SMS_LABEL) {
      this.showContactNumber = false;
    } else {
      this.showContactNumber = true;
    }
    if (this.communicationMode === resources.PHONE_LABEL) {
      this.showContactNumber = true;
    } else {
      this.showContactNumber = false;
    }
    if (!this.communicationMode || this.communicationMode === null) {
      this.pcmErrorMessage = true;
      this.template.querySelector(
        'lightning-combobox[data-field="PreferredMethodofCommunication"]'
      ).className = "textInput-err";
      this.template.querySelector(
        'label[data-field="PreferredMethodofCommunication"]'
      ).className = "input-error-label";
    } else {
      this.pcmErrorMessage = false;
      this.template.querySelector(
        'lightning-combobox[data-field="PreferredMethodofCommunication"]'
      ).className = "textInput";
      this.template.querySelector(
        'label[data-field="PreferredMethodofCommunication"]'
      ).className = "input-label";
    }
  }

  validateAllData() {
    if (!this.firstName) {
      this.firstNameErrorMessage = true;
      this.template.querySelector(
        'lightning-input[data-field="FirstName"]'
      ).className = "textInput-err";
      this.template.querySelector('label[data-field="FirstName"]').className =
        "input-error-label";
      this.validateform = true;
    } else {
      this.firstNameErrorMessage = false;
      this.firstNameErrorMessageValid = false;
      if (!/^[a-zA-ZÀ-ž\s\-'.`]+$/u.test(this.firstName)) {
        this.firstNameErrorMessage = false;
        this.firstNameErrorMessageValid = true;
        this.template
          .querySelector('lightning-input[data-field="FirstName"]')
          .classList.add("textInput-err");
        this.template
          .querySelector('label[data-field="FirstName"]')
          .classList.add("input-error-label");
        this.validateform = true;
      } else {
        this.firstNameErrorMessage = false;
        this.firstNameErrorMessageValid = false;
      }
    }
    if (!this.lastName) {
      this.lastNameErrorMessage = true;
      this.template.querySelector(
        'lightning-input[data-field="LastName"]'
      ).className = "textInput-err";
      this.template.querySelector('label[data-field="LastName"]').className =
        "input-error-label";
      this.validateform = true;
    } else {
      this.lastNameErrorMessageValid = false;
      this.lastNameErrorMessage = false;
      if (!/^[a-zA-ZÀ-ž\s\-'.`]+$/u.test(this.lastName)) {
        this.lastNameErrorMessage = false;
        this.lastNameErrorMessageValid = true;
        this.template.querySelector(
          'lightning-input[data-field="LastName"]'
        ).className = "textInput-err";
        this.template.querySelector('label[data-field="LastName"]').className =
          "input-error-label";
        this.validateform = true;
      } else {
        this.lastNameErrorMessageValid = false;
        this.lastNameErrorMessage = false;
      }
    }
    if (this.birthDate === "") {
      this.dobErrorMessage = true;
      this.template.querySelector(
        'input[data-field="Birthdate"]'
      ).className = "dateText-err";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-error-label";

      this.validateform = true;
    }

    if (!this.communicationMode || this.communicationMode === null) {
      this.pcmErrorMessage = true;
      this.template.querySelector(
        'lightning-combobox[data-field="PreferredMethodofCommunication"]'
      ).className = "textInput-err";
      this.template.querySelector(
        'label[data-field="PreferredMethodofCommunication"]'
      ).className = "input-error-label";
      this.validateform = true;
    }

    if (
      this.communicationMode === resources.SMS_LABEL ||
      this.communicationMode === resources.PHONE_LABEL
    ) {
      if (
        !this.phoneRecord ||
        this.phoneRecord === "" ||
        this.phoneRecord.length === 0
      ) {
        this.phoneErrorMessage = true;
        this.template.querySelector(
          'lightning-input[data-field="MobilePhone"]'
        ).className = "textInput-err";
        this.template.querySelector(
          'label[data-field="MobilePhone"]'
        ).className = "input-error-label";
        this.template
          .querySelector('lightning-input[data-field="MobilePhone"]')
          .classList.add("textInput-err");
        this.template
          .querySelector('label[data-field="MobilePhone"]')
          .classList.add("input-error-label");
        this.validateform = true;
      }
    }
    if (this.communicationMode === resources.EMAIL_LABEL) {
      if (this.phoneRecord.length < 10 && this.phoneRecord.length !== 0) {
        this.phoneErrorMessage = true;
        this.template.querySelector(
          'lightning-input[data-field="MobilePhone"]'
        ).className = "textInput-err";
        this.template.querySelector(
          'label[data-field="MobilePhone"]'
        ).className = "input-error-label";
        this.template
          .querySelector('lightning-input[data-field="MobilePhone"]')
          .classList.add("textInput-err");
        this.template
          .querySelector('label[data-field="MobilePhone"]')
          .classList.add("input-error-label");
        this.validateform = true;
      } else {
        this.phoneErrorMessage = false;
      }
    }
  }

  validateSecondPart() {
    if (!this.relationshipVal) {
      this.relationshipErrorMessage = true;
      this.template.querySelector(
        'lightning-combobox[data-field="Relationship"]'
      ).className = "textInput-err";
      this.template.querySelector(
        'label[data-field="Relationship"]'
      ).className = "input-error-label";
    } else {
      this.relationshipErrorMessage = false;
      this.template.querySelector(
        'lightning-combobox[data-field="Relationship"]'
      ).className = "textInput";
      this.template.querySelector(
        'label[data-field="Relationship"]'
      ).className = "input-label";
    }
    if (!this.birthDate || this.birthDate === null) {
      this.dobErrorMessage = true;
      this.template.querySelector(
        'lightning-combobox[data-field="Birthdate"]'
      ).className = "dateText-err";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-error-label";
    }
  }

  handleFinalData() {
    this.validateform = false;
    this.validateAllData();
    this.validateSecondPart();
    if (this.futureError === true || this.minorerror === true) {
      let BirthdateField = this.template.querySelector(
        'input[data-field="Birthdate"]'
      );
      BirthdateField.className = "dateText-err";
      this.template.querySelector('label[data-field="Birthdate"]').className =
        "input-error-label";
    }
    if (this.validateform === true || this.futureError === true) {
      return;
    }

    if (this.birthDate === "" || this.birthDate === null) {
      this.dobErrorMessage = true;
    }
    if (
      this.communicationMode === "" ||
      this.communicationMode === null ||
      this.communicationMode.length === 0 ||
      this.communicationMode === resources.UNDEFINED_VALUE
    ) {
      this.pcmErrorMessage = true;
    }
    if (
      this.firstName === "" ||
      this.firstName === null ||
      this.firstName.length === 0
    ) {
      this.FirstNameErrorMessage = true;
    }

    if (
      this.lastName === "" ||
      this.lastName === null ||
      this.lastName.length === 0
    ) {
      this.lastNameErrorMessage = true;
    }

    if (this.minorerror === true) {
      this.validateform = true;
    }
    if (this.validateform === true) {
      return;
    }
    let addcaregiverDetails = {
      accountId: this.accountIdVal,
      firstName: this.firstName,
      lastName: this.lastName,
      personEmail: this.personEmailVal,
      personBirthdate: this.birthDate,
      relations: this.relationshipVal,
      phone: this.phoneRecord,
      preferredMethodOfContact: this.communicationMode
    };

    UPDATE_CAREGIVER_DETAILS({
      cgprofile: addcaregiverDetails
    })
      .then(() => {
        this.updatePopup = true;
        window.scrollTo({ top: 0, behavior: "smooth" });
        // Handle success, if needed
      })
      .catch((err) => {
        this.error = resources.CAREGIVER_NOT_UPDATE;
        this.navigateToErrorPage(err.body.message);
      });
  }

  handleCancel() {
    // Reload page if cancel action is clicked
    window.location.reload();
  }

  /*There's no need to check for null because in Apex, we're throwing an AuraHandledException. 
  Therefore, null data won't be encountered.*/
  // To reterieve the caregiver name and avatar
  @wire(USER_CAREGIVERS)
  wiredavtList({ error, data }) {
    try {
      if (data && data.length > 0) {
        // Assign the data to the reactive property
        if (data.length > 0) {
          this.caregiver = true;

          if (data[0]?.PSP_BR_Patient__r?.PSP_BR_c__c) {
            this.selectedAvatarSrc = data[0]?.PSP_BR_Patient__r?.PSP_BR_c__c;
          } else {
            this.selectedAvatarSrc = this.defaultImg;
          }
        } else if (error) {
          this.navigateToErrorPage(error.body.message);
        }
      }
    } catch (err) {
      this.error = resources.CAREGIVER_NOT_FOUND;
      this.navigateToErrorPage(err.message);
    }
  }

  // To allow only letters as input
  handleKeyDownName(event) {
    let allowedCharacters = /^[A-Za-z]+$/u;
    if (!allowedCharacters.test(event.key)) {
      event.preventDefault();
    }
  }

  // Not allow user to type date of birth only allow to select date value
  handleKeyDownThree(event) {
    event.preventDefault();
  }

  // Not allow paste event in firstname and last name
  handlePaste(event) {
    // Prevent default paste behavior
    event.preventDefault();
  }

  // Allow only numbers 0-9 and + symbol for mobile number
  handleKeyDown(event) {
    // Get the keycode of the pressed key
    let keyCode = event.keyCode || event.which;

    // Allow the backspace key (keyCode 8)
    if (keyCode === 8) {
      return;
    }

    // Define the allowed characters regex
    let allowedCharacters = /^[0-9+]+$/u;

    // Check if the pressed key matches the allowed characters
    if (!allowedCharacters.test(event.key)) {
      // If not, prevent the default action (input of the character)
      event.preventDefault();
    }
  }

  // To load combobox text align style
  connectedCallback() {
    try {
      loadStyle(this, resources.TEXT_ALIGN);
    } catch (err) {
      this.error = resources.RECORD_NOT_FOUND;
      this.navigateToErrorPage(err.message);
    }
  }
  

  handleSubmitDetail() {
 
 const emailInput = this.template.querySelector('lightning-input[data-field="email"]');
  const emailLabel = this.template.querySelector('label[data-field="email"]');
    if (!this.personEmailVal || this.personEmailVal.length === 0) {
this.emailErrorMessage = true;
this.deleteButton = false;
            if (emailInput) {
           
                emailInput.className = 'textInput-err'; // Apply error class
                emailLabel.className = "input-error-label"; // Set error class
                this.deleteButton = false;
                
            }
            if (emailLabel) {
              this.deleteButton = false;
                emailLabel.className = 'input-error-label'; // Apply error class
            }
    }
    else if (this.changeEmail === true) {
      this.deleteButton = true;
      
      document.body.style.overflow = "";
    } else {
      this.validateFirstName();
      this.validateLastName();
      this.validateBirthdate();
    }
  }
  uniqueEmail;

handle_Email(event) {
    this.personEmailVal = event.target.value; // Set the new email value
    this.changeEmail = true;

    const emailInput = this.template.querySelector('lightning-input[data-field="email"]');
    const emailLabel = this.template.querySelector('label[data-field="email"]');

    // Check if email value is empty
    if (!this.personEmailVal || this.personEmailVal.length === 0) {
        this.emailErrorMessage = true;
        this.deleteButton = false;

        if (emailInput) {
            emailInput.className = 'textInput-err'; // Apply error class
        }
        if (emailLabel) {
            emailLabel.className = 'input-error-label'; // Apply error class
        }
        return; // Exit the method early if email is empty
    }

    // Clear previous error states
    this.emailErrorMessage = false;
    this.matchEmail = false;

    // Proceed with checking existing accounts
    GET_EXISTING_ACCOUNTS({ email: this.personEmailVal }).then((result) => {
        if (result && result.length > 0) {
            this.uniqueEmail = result.map((item) => item.PersonEmail);

            if (this.uniqueEmail.includes(this.personEmailVal)) {
                this.matchEmail = true;

                if (emailInput) {
                    emailInput.className = 'textInput-err'; // Apply error class for match
                }
                if (emailLabel) {
                    emailLabel.className = 'input-error-label'; // Apply error class for match
                }
            } else {
                this.hasEmailChanged = true;

                if (emailInput) {
                  
                    emailInput.className = 'textInput'; // Remove error class
                }
                if (emailLabel) {
                    emailLabel.className = 'input-label'; // Remove error class
                }
            }
        } else {
            this.hasEmailChanged = true;

            if (emailInput) {
              this.matchEmail = false;
                emailInput.className = 'textInput'; // Remove error class
            }
            if (emailLabel) {
              this.matchEmail = false;
                emailLabel.className = 'input-label'; // Remove error class
            }
        }
    }).catch((error) => {
        // Handle any errors from GET_EXISTING_ACCOUNTS
       this.error = resources.CAREGIVER_NOT_FOUND;
      this.navigateToErrorPage(error.message);
        // Optionally handle error state if necessary
    });
}


  deleteButton = false;
  changeEmail = false;

  handleDeleteBtn() {
    this.validateFirstName();
    this.validateLastName();
    this.validateBirthdate();
    this.deleteButton = false;
    window.location.reload();
  }

  closeEdit() {
    this.deleteButton = false;
    document.body.style.overflow = ""; // Reset to default

    // Reset email if it was changed
    if (this.changeEmail && this.changeName) {
        this.handleFinalData();
        this.personEmailVal = this.patientEmailold;
    }

      else if(this.changeEmail){
      this.personEmailVal = this.patientEmailold;
      this.changeEmail = false; // Reset the flag
      
    }
    
    

  }

  closedeletbtnadd() {
    // Add your specific logic for closing the mood modal
    this.deleteButton = false;
    document.body.style.overflow = "";

    // Reset to default
  }

  // showToast used for all the error messages caught
  navigateToErrorPage(message) {
    let globalThis = window;
    globalThis.sessionStorage.setItem("errorMessage", message);
    globalThis.location.href = resources.ERROR_PAGE;
  }
}