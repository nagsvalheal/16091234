/** 
 * @description       : Apex class for Commonly used custom labels for Questionnaires.
 * History:
 * Version  Author      Date            Detail          Description
 * 1.0      Abinsha     07-jul-2024    Created         Initial development.
 */
public inherited sharing class BI_PSP_QuestionnaireConstant {
    public static String unableToInsert= System.Label.BI_PSP_UnableToInsert;
    public static String unableToUpdate= System.Label.BI_PSP_UnableToUpdate;
    public static String unableToUpsert= System.Label.BI_PSP_UnableToUpsert;
    public static String unableToDelete= System.Label.BI_PSP_UnableToDelete;
	public static String userNotFound= System.Label.BI_PSP_NoUserFound;
    public static String noEnroleeOrAssessment= System.Label.BI_PSP_EnrolleeOrAssessment;
    public static Boolean withSharingKeywrd = Boolean.valueOf(System.Label.BI_PSP_UserModeFalse);
	public static String symptomErrorMsg = System.Label.BI_PSP_SymptomTrackerError;
    public static String symptomStatusInactive = System.Label.BI_PSP_Inactive;
    public static String errorForDates = System.Label.BI_PSP_QualitativeDateError;
    public static String falseParemeter = System.Label.BI_PSP_FalseInputParameters;
    public static String expiredLabel = System.Label.BI_PSP_Expired;
    public static String active = System.Label.BI_PSP_Active;
    public static String emptyCategoryName = System.Label.BI_PSP_EmptyCategoryError;
    public static String acute = System.Label.BI_PSP_Acute;
    public static String chronic = System.Label.BI_PSP_Chronic;
    public static String unassigned = System.Label.BI_PSP_Unassigned;
    public static String emptyEnrolleRecrd = System.Label.BI_PSP_EmptyCareProgramEnrl;
    public static String conditions;
    public static String careGiversPatientAccountErr = System.Label.BI_PSP_CaregiversPatient;
    public static final String LOG_SEVERITY_INFO = System.Label.BI_PSP_InfoSeverity;
    public static final String LOG_SEVERITY_ERROR  = System.Label.BI_PSP_ErrorSeverity;
    public static String careGiversSelectedPatientErrMsg = System.Label.BI_PSP_SelectedPatientAccount;
    public static String selctdPatientEnrolleeErrorMsg = System.Label.BI_PSP_SelectedPatientEnrollee;
    public static String patientAccountErrorMsg = System.Label.BI_PSP_PatientAccountError;
    public static String patientEnrolleeErrorMsg = System.Label.BI_PSP_PatientEnrolleeError;
    public static  String introduction = System.Label.BI_PSP_IntroductionTxt;
    public static  String inProgress = System.Label.BI_PSP_InProgressTxt;
    public static  String complete = System.Label.BI_PSP_Complete;
    public static  String emptyQuestioniareResponse = System.Label.BI_PSP_EmptyQuestionResponse;
    public static  String emptyAssesment = System.Label.BI_PSP_EmptyAssessment;
    public static  String emptyQuestionVersion = System.Label.BI_PSP_EmptyQuestionVersion;
    public static  String questionsNotAvailable = System.Label.BI_PSP_QuestionsUnavailable;
    public static  String assessmentFailed = System.Label.BI_PSP_AssessmentSubFailed;
    public static  String respnsNotDeltd = System.Label.BI_PSP_RespDelFailed;
    public static  String errorPersnltnStatus = System.Label.BI_PSP_PersnlatnStatus;
    public static String priorityHigh=System.Label.BI_PSPB_PriorityHigh;
     public static String emptyAssessmentDate = System.Label.BI_PSP_EmptyCompletedDate;
     public static Integer twoMonthsInt = Integer.valueOf(
        System.Label.BI_PSP_QsqAfterTwoMonths
    );
    public static Integer fourteenWeeksInt = Integer.valueOf(
        System.Label.BI_PSP_QsqAfterFourteenWeeks
    );
    public static String rolloutDateerrormessage = System.Label.BI_PSP_RolloutErrorMsg;
    public static String completed = System.Label.BI_PSP_Completed;
    public static Integer expireDate = Integer.valueOf(System.Label.BI_PSP_ExpireDateForQualitative);
    public static String pageOne = System.Label.BI_PSP_PageOne;
    public static String pageTwo = System.Label.BI_PSP_PageTwo;
    public static String qualiCategory = System.Label.BI_PSP_QualitativeCategory;
     public static String applicationName;
    static {
        BI_SFCOE_LOG_App_Settings__c settings = BI_SFCOE_LOG_App_Settings__c.getValues('PSPB');
        applicationName = settings != null ? settings.BI_SFCOE_LOG_Application__c : '';
    }
    
}