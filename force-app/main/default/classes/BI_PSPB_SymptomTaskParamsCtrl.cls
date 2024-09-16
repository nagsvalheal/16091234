public with sharing class BI_PSPB_SymptomTaskParamsCtrl {
    public List<Id> enrollees;
    public List<Id> caregiverIds;
    public String notificationType;
    public String category;
    public String treatmentType;
    public String status;
    public String userType;
    public String subject;

    // Private constructor to enforce use of the builder
    private BI_PSPB_SymptomTaskParamsCtrl(Builder builder) {
        this.enrollees = builder.enrollees;
        this.caregiverIds = builder.caregiverIds;
        this.notificationType = builder.notificationType;
        this.category = builder.category;
        this.treatmentType = builder.treatmentType;
        this.status = builder.status;
        this.userType = builder.userType;
        this.subject = builder.subject;
    }

    // Nested Builder Class
    public class Builder {
        public List<Id> enrollees = new List<Id>();
        public List<Id> caregiverIds = new List<Id>();
        public String notificationType;
        public String category;
        public String treatmentType = '';
        public String status;
        public String userType;
        public String subject;

        // Methods to set each field, returning the builder for chaining
        public Builder setEnrollees(List<Id> enrollees) {
            this.enrollees = enrollees;
            return this;
        }

        public Builder setCaregiverIds(List<Id> caregiverIds) {
            this.caregiverIds = caregiverIds;
            return this;
        }

        public Builder setNotificationType(String notificationType) {
            this.notificationType = notificationType;
            return this;
        }

        public Builder setCategory(String category) {
            this.category = category;
            return this;
        }

        public Builder setTreatmentType(String treatmentType) {
            this.treatmentType = treatmentType;
            return this;
        }

        public Builder setStatus(String status) {
            this.status = status;
            return this;
        }

        public Builder setUserType(String userType) {
            this.userType = userType;
            return this;
        }

        public Builder setSubject(String subject) {
            this.subject = subject;
            return this;
        }

        // Method to build and return the TaskCreationParams object
        public BI_PSPB_SymptomTaskParamsCtrl build() {
            return new BI_PSPB_SymptomTaskParamsCtrl(this);
        }
    }
}