/**
 * Created by osman on 8.10.2020.
 */

public with sharing class EUR_TR_POSMApprovalController {
    public class EUR_TR_POSMApprovalControllerException extends Exception {
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse isApprovalProcessRequiredByPOSMFields(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;
        Boolean isApprovalProcessRequired = false;

        try {

            if (String.isBlank(requestBody)) {
                throw new EUR_TR_POSMApprovalControllerException('Geçersiz istek , model boş gönderilemez!');
            }

            POSMApprovalRequestModel request = (POSMApprovalRequestModel) JSON.deserialize(requestBody, POSMApprovalRequestModel.class);
            checkPOSMRequestIsValid(request);

            EUR_TR_POSMDefinitionController.POSMSubTypeRequestModel POSMSubTypeRequestModel = new EUR_TR_POSMDefinitionController.POSMSubTypeRequestModel(request.EURTRPOSMRecord);
            Map<String, EUR_TR_Definition__c> POSMSubTypeDefinitionMap = EUR_TR_POSMDefinitionController.getPOSMSubTypeDefinitionMap(POSMSubTypeRequestModel);
            if (!POSMSubTypeDefinitionMap.containsKey(request.EURTRPOSMRecord.EUR_TR_RelatedPOSMSubType__c)) {
                throw new EUR_TR_POSMApprovalControllerException('Geçersiz ürün alt tipi,seçilen ürün alt tipi ile ilgili tanım bulunamadı. Lütfen ürün alt tipini değiştirip yeniden deneyiniz.');
            }

            EUR_TR_Definition__c POSMSubTypeDefinition = POSMSubTypeDefinitionMap.get(request.EURTRPOSMRecord.EUR_TR_RelatedPOSMSubType__c);
            checkPOSMRecordIsValidByDefinition(request, POSMSubTypeDefinition);

            Decimal unitPrice = null;
            if (POSMSubTypeDefinition.EUR_TR_UnitPrice__c != null) {
                unitPrice = POSMSubTypeDefinition.EUR_TR_UnitPrice__c;
                request.EURTRPOSMRecord.EUR_TR_Budget__c = POSMSubTypeDefinition.EUR_TR_UnitPrice__c * request.EURTRPOSMRecord.EUR_TR_POSMQuantity__c;
            }

            if (isApprovalProcessRequiredByBudgetDefinition(request, POSMSubTypeDefinition)) {
                isApprovalProcessRequired = true;
            } else if (isApprovalProcessRequiredByPOSMTypeDefinition(request, POSMSubTypeDefinition)) {
                isApprovalProcessRequired = true;
            } else {
                isApprovalProcessRequired = false;
            }

            Map<String, Boolean> responseMap = new Map<String, Boolean>();
            responseMap.put('isApprovalProcessRequired', isApprovalProcessRequired);

            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = responseMap;


        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse createPOSMRequest(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;
        Boolean isApprovalProcessRequired = false;

        try {

            if (String.isBlank(requestBody)) {
                throw new EUR_TR_POSMApprovalControllerException('Geçersiz istek , model boş gönderilemez!');
            }

            POSMApprovalRequestModel request = (POSMApprovalRequestModel) JSON.deserialize(requestBody, POSMApprovalRequestModel.class);
            checkPOSMRequestIsValid(request);

            EUR_TR_POSMDefinitionController.POSMSubTypeRequestModel POSMSubTypeRequestModel = new EUR_TR_POSMDefinitionController.POSMSubTypeRequestModel(request.EURTRPOSMRecord);
            Map<String, EUR_TR_Definition__c> POSMSubTypeDefinitionMap = EUR_TR_POSMDefinitionController.getPOSMSubTypeDefinitionMap(POSMSubTypeRequestModel);
            if (!POSMSubTypeDefinitionMap.containsKey(request.EURTRPOSMRecord.EUR_TR_RelatedPOSMSubType__c)) {
                throw new EUR_TR_POSMApprovalControllerException('Geçersiz ürün alt tipi,seçilen ürün alt tipi ile ilgili tanım bulunamadı. Lütfen ürün alt tipini değiştirip yeniden deneyiniz.');
            }
            EUR_TR_Definition__c POSMSubTypeDefinition = POSMSubTypeDefinitionMap.get(request.EURTRPOSMRecord.EUR_TR_RelatedPOSMSubType__c);
            checkPOSMRecordIsValidByDefinition(request, POSMSubTypeDefinition);

            Decimal unitPrice = null;
            if (POSMSubTypeDefinition.EUR_TR_UnitPrice__c != null) {
                unitPrice = POSMSubTypeDefinition.EUR_TR_UnitPrice__c;
                request.EURTRPOSMRecord.EUR_TR_Budget__c = POSMSubTypeDefinition.EUR_TR_UnitPrice__c * request.EURTRPOSMRecord.EUR_TR_POSMQuantity__c;
            }

            EUR_TR_POSM__c POSMRecord = new EUR_TR_POSM__c();
            EUR_TR_Approval__c approval = new EUR_TR_Approval__c();

            if (request.EURTRPOSMApprovalRecord == null || request.EURTRPOSMApprovalRecord.Id == null) {
                request.EURTRPOSMApprovalRecord = approval;
            }


            if (isApprovalProcessRequiredByBudgetDefinition(request, POSMSubTypeDefinition)) {

                setApprovalFieldsByBudgetDefinition(request, POSMSubTypeDefinition);
                POSMRecord = request.EURTRPOSMRecord;
                POSMRecord.EUR_TR_UnitPrice__c = unitPrice;
                upsert POSMRecord;
                approval = request.EURTRPOSMApprovalRecord;
                approval.EUR_TR_RelatedPOSM__c = POSMRecord.Id;
                approval.RecordTypeId = Schema.SObjectType.EUR_TR_Approval__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMApproval').getRecordTypeId();
                upsert approval;
                successMessage = 'POSM talebiniz onaya gönderilmiştir.';
                isApprovalProcessRequired = true;
                insertPOSMApprovalRecordHistory(approval);

            } else if (isApprovalProcessRequiredByPOSMTypeDefinition(request, POSMSubTypeDefinition)) {

                setApprovalFieldsByPOSMTypeDefinition(request, POSMSubTypeDefinition);
                POSMRecord = request.EURTRPOSMRecord;
                POSMRecord.EUR_TR_UnitPrice__c = unitPrice;
                upsert POSMRecord;
                approval = request.EURTRPOSMApprovalRecord;
                approval.EUR_TR_RelatedPOSM__c = POSMRecord.Id;
                upsert approval;
                successMessage = 'POSM talebiniz onaya gönderilmiştir.';
                isApprovalProcessRequired = true;
                insertPOSMApprovalRecordHistory(approval);

            } else {

                // will be created record directly without any approval process
                POSMRecord = request.EURTRPOSMRecord;
                POSMRecord.EUR_TR_ApprovalStatus__c = APPROVED;
                POSMRecord.EUR_TR_UnitPrice__c = unitPrice;
                upsert POSMRecord;
                successMessage = 'POSM kaydınız başarılı bir şekilde oluşturulmuştur.';
                isApprovalProcessRequired = false;

                // send vendor to email
                if (POSMSubTypeDefinition.EUR_TR_IsCarpenterPOSMType__c && request.isVendorEmailFieldsControlRequired) {
                    sendEmailToVendor(request.vendorEmailAddress, request.emailBody);
                }

            }

            if (isApprovalProcessRequired) {
                Boolean isSentEmailSuccessfully = sendApprovalEmail(approval);
                EUR_TR_POSMApprovalNotificationHelper.sendNotificationByPOSMApprovalRecord(approval, isSentEmailSuccessfully);
            } else {
                EUR_TR_POSMApprovalNotificationHelper.sendNotificationByPOSMRecord(POSMRecord, successMessage);
            }


            serviceResponse.Message = successMessage;
            serviceResponse.ExtensionData = [
                    SELECT
                            Id,
                            Name,
                            EUR_TR_ApprovalStatus__c,
                            EUR_TR_Brand__c,
                            EUR_TR_BrandOther__c,
                            EUR_TR_Budget__c,
                            EUR_TR_PlacementDate__c,
                            EUR_TR_POSMType__c,
                            EUR_TR_RelatedAccount__c,
                            EUR_TR_RelatedAccount__r.Name,
                            EUR_TR_RelatedAccount__r.EUR_TR_AccountCode__c,
                            EUR_TR_POSMQuantity__c,
                            CreatedDate,
                            OwnerId,
                            Owner.Name
                            , (
                            SELECT Id,Name,
                                    EUR_TR_Approver__r.Name,EUR_TR_Submitter__r.Name,
                                    EUR_TR_ApprovalStatus__c,EUR_TR_ApprovalReason__c,EUR_TR_ApprovalProcessType__c
                            FROM EUR_TR_POSM_Approvals__r
                            WHERE RecordType.DeveloperName = 'EUR_TR_POSMApproval'
                            ORDER BY CreatedDate DESC
                            LIMIT 1
                    )
                    FROM EUR_TR_POSM__c
                    WHERE RecordType.DeveloperName = 'EUR_TR_POSM' AND Id = :POSMRecord.Id
                    AND EUR_TR_RelatedAccount__c = :request.EURTRPOSMRecord.EUR_TR_RelatedAccount__c
                    ORDER BY CreatedDate DESC
            ];


        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse handleApprovalAction(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;

        try {

            POSMApprovalRequestModel request = (POSMApprovalRequestModel) JSON.deserialize(requestBody, POSMApprovalRequestModel.class);
            System.debug(JSON.serializePretty(request));
            checkApprovalRecordIsValidToApprovalActions(request);


            EUR_TR_Approval__c approval = null;
            EUR_TR_POSM__c POSMRecord = null;

            if (String.isNotBlank(request.EURTRPOSMApprovalRecord.Id)) {

                approval = [
                        SELECT Id,EUR_TR_ApprovalProcessType__c,
                                EUR_TR_RelatedPOSM__c,EUR_TR_ApprovalStatus__c,
                                EUR_TR_Approver__c,EUR_TR_Submitter__c,
                                EUR_TR_RelatedPOSM__r.Id,
                                EUR_TR_RelatedPOSM__r.EUR_TR_ApprovalStatus__c,
                                EUR_TR_RelatedPOSM__r.EUR_TR_Brand__c,
                                EUR_TR_RelatedPOSM__r.EUR_TR_BrandOther__c,
                                EUR_TR_RelatedPOSM__r.EUR_TR_Budget__c,
                                EUR_TR_RelatedPOSM__r.EUR_TR_PlacementDate__c,
                                EUR_TR_RelatedPOSM__r.EUR_TR_POSMType__c,
                                EUR_TR_RelatedPOSM__r.EUR_TR_POSMQuantity__c,
                                EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__c,
                                EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__c,
                                EUR_TR_RelatedPOSM__r.EUR_TR_UnitPrice__c
                        FROM EUR_TR_Approval__c
                        WHERE Id = :request.EURTRPOSMApprovalRecord.Id
                ];
                if (request.EURTRPOSMRecord == null) {
                    request.EURTRPOSMRecord = new EUR_TR_POSM__c();
                }
                request.EURTRPOSMApprovalRecord = approval;
                if (approval.EUR_TR_ApprovalProcessType__c == 'Revize Talebi') {
                    // update is enabled for Revise Request
                    checkPOSMRequestIsValid(request);
                } else {
                    request.EURTRPOSMRecord = approval.EUR_TR_RelatedPOSM__r;
                }

            } else if (String.isNotBlank(request.EURTRPOSMRecord.Id)) {

                POSMRecord = [
                        SELECT
                                Id,
                                EUR_TR_ApprovalStatus__c,
                                EUR_TR_Brand__c,
                                EUR_TR_BrandOther__c,
                                EUR_TR_Budget__c,
                                EUR_TR_PlacementDate__c,
                                EUR_TR_POSMType__c,
                                EUR_TR_POSMQuantity__c,
                                EUR_TR_RelatedAccount__c,
                                EUR_TR_RelatedPOSMSubType__c,
                                EUR_TR_UnitPrice__c
                        FROM EUR_TR_POSM__c
                        WHERE Id = :request.EURTRPOSMRecord.Id
                ];
                request.EURTRPOSMRecord = POSMRecord;

            }

            if (request.actionName == APPROVED) {
                handleApproveAction(request);
            } else if (request.actionName == CANCELED) {
                handleCancelAction(request);
            } else if (request.actionName == REVISE) {
                handleReviseAction(request);
            } else if (request.actionName == REJECTED) {
                handleRejectAction(request);
            }

            serviceResponse.Message = successMessage;
            serviceResponse.ExtensionData = [
                    SELECT Id,EUR_TR_ApprovalStatus__c,EUR_TR_ApprovalReason__c,
                            EUR_TR_Approver__c,EUR_TR_Submitter__c,EUR_TR_ApprovalProcessType__c,
                            EUR_TR_RelatedPOSM__r.Id,
                            EUR_TR_RelatedPOSM__r.EUR_TR_ApprovalStatus__c
                    FROM EUR_TR_Approval__c
                    WHERE Id = :request.EURTRPOSMApprovalRecord.Id
            ];

        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getPOSMApprovalRecordsFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;

        try {

            POSMApprovalFilterModel approvalFilterModel = (POSMApprovalFilterModel) JSON.deserialize(requestBody, POSMApprovalFilterModel.class);
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getPOSMApprovalRecords(approvalFilterModel);

        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getApprovalRecordHistoryFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;
        serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;

        try {

            EUR_TR_Approval__c POSMApprovalRecord = (EUR_TR_Approval__c) JSON.deserialize(requestBody, EUR_TR_Approval__c.class);
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getPOSMApprovalRecordHistory(POSMApprovalRecord);

        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getPOSMDetailByApprovalIdFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;

        try {

            if (String.isBlank(requestBody)) {
                throw new EUR_TR_POSMApprovalControllerException('Geçersiz istek , model boş gönderilemez!');
            }

            EUR_TR_Approval__c approval = (EUR_TR_Approval__c) JSON.deserialize(requestBody, EUR_TR_Approval__c.class);

            if (String.isBlank(approval.Id)) {
                throw new EUR_TR_POSMApprovalControllerException('Onay parametresi boş gönderilemez');
            }

            POSMApprovalFilterModel approvalFilterModel = new POSMApprovalFilterModel();
            approvalFilterModel.approvalId = approval.Id;
            approvalFilterModel.pageNumber = 1;
            approvalFilterModel.pageSize = 1;

            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getPOSMApprovalRecords(approvalFilterModel);

        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getApprovalActorsFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;

        try {

            POSMApprovalFilterModel approvalFilterModel = (POSMApprovalFilterModel) JSON.deserialize(requestBody, POSMApprovalFilterModel.class);
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getApprovalActors(approvalFilterModel);

        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getPOSMSubTypeFilterOptionsFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;

        try {

            POSMApprovalFilterModel approvalFilterModel = (POSMApprovalFilterModel) JSON.deserialize(requestBody, POSMApprovalFilterModel.class);
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getPOSMSubTypeFilterOptions(approvalFilterModel);

        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;
    }


    private static void checkPOSMRequestIsValid(POSMApprovalRequestModel requestModel) {
        if (requestModel == null) {
            throw new EUR_TR_POSMApprovalControllerException('Geçersiz istek , istek boş gönderilemez.');
        } else if (String.isBlank(requestModel.EURTRPOSMRecord.EUR_TR_RelatedAccount__c)) {
            throw new EUR_TR_POSMApprovalControllerException('İlgili müşteri(EUR_TR_RelatedAccount__c) alanı boş bırakılamaz!');
        } else if (String.isBlank(requestModel.EURTRPOSMRecord.EUR_TR_POSMType__c)) {
            throw new EUR_TR_POSMApprovalControllerException('Ürün tipi bilgisi boş bırakılamaz!');
        } else if (requestModel.EURTRPOSMRecord.EUR_TR_PlacementDate__c == null) {
            throw new EUR_TR_POSMApprovalControllerException('Teslimat tarihi bilgisi boş bırakılamaz!');
        } else if (String.isBlank(requestModel.EURTRPOSMRecord.EUR_TR_Brand__c)) {
            throw new EUR_TR_POSMApprovalControllerException('Marka bilgisi boş bırakılamaz!');
        } else if (requestModel.EURTRPOSMRecord.EUR_TR_Brand__c == 'Other' && String.isBlank(requestModel.EURTRPOSMRecord.EUR_TR_BrandOther__c)) {
            throw new EUR_TR_POSMApprovalControllerException('Diğer Marka bilgisi boş bırakılamaz!');
        } else if (String.isBlank(requestModel.EURTRPOSMRecord.EUR_TR_RelatedPOSMSubType__c)) {
            throw new EUR_TR_POSMApprovalControllerException('Ürün alt tipi seçimi boş bırakılamaz');
        }
    }

    private static void checkPOSMRecordIsValidByDefinition(POSMApprovalRequestModel requestModel, EUR_TR_Definition__c POSMTypeDefinition) {

        if (POSMTypeDefinition.EUR_TR_UnitPrice__c == null && requestModel.EURTRPOSMRecord.EUR_TR_Budget__c == null) {
            throw new EUR_TR_POSMApprovalControllerException('Bütçe bilgisi boş bırakılamaz!');
        } else if (POSMTypeDefinition.EUR_TR_UnitPrice__c != null && requestModel.EURTRPOSMRecord.EUR_TR_POSMQuantity__c == null) {
            throw new EUR_TR_POSMApprovalControllerException('Adet/m2 alanı boş bırakılamaz!');
        }

    }

    private static void checkApprovalRecordIsValidToApprovalActions(POSMApprovalRequestModel requestModel) {

        if (requestModel.actionName == null) {
            throw new EUR_TR_POSMApprovalControllerException('Aksiyon bilgisi boş bırakılamaz!');
        } else if (!(requestModel.actionName == APPROVED || requestModel.actionName == CANCELED || requestModel.actionName == REJECTED || requestModel.actionName == REVISE)) {
            throw new EUR_TR_POSMApprovalControllerException('Bilinmeyen aksiyon!');
        } else if ((requestModel.EURTRPOSMApprovalRecord == null || String.isBlank(requestModel.EURTRPOSMApprovalRecord.Id)) && (requestModel.EURTRPOSMRecord == null || String.isBlank(requestModel.EURTRPOSMRecord.Id))) {
            throw new EUR_TR_POSMApprovalControllerException('POSM talebinde ID bilgisi boş olamaz!');
        }

    }

    private static void handleApproveAction(POSMApprovalRequestModel requestModel) {

        EUR_TR_POSMDefinitionController.POSMSubTypeRequestModel POSMSubTypeRequestModel = new EUR_TR_POSMDefinitionController.POSMSubTypeRequestModel(requestModel.EURTRPOSMRecord);
        Map<String, EUR_TR_Definition__c> POSMSubTypeDefinitionMap = EUR_TR_POSMDefinitionController.getPOSMSubTypeDefinitionMap(POSMSubTypeRequestModel);
        if (!POSMSubTypeDefinitionMap.containsKey(requestModel.EURTRPOSMRecord.EUR_TR_RelatedPOSMSubType__c)) {
            throw new EUR_TR_POSMApprovalControllerException('Geçersiz ürün alt tipi,seçilen ürün alt tipi ile ilgili tanım bulunamadı. Lütfen ürün alt tipini değiştirip yeniden deneyiniz.');
        }

        EUR_TR_Definition__c POSMSubTypeDefinition = POSMSubTypeDefinitionMap.get(requestModel.EURTRPOSMRecord.EUR_TR_RelatedPOSMSubType__c);

        if (String.isNotBlank(requestModel.EURTRPOSMRecord.EUR_TR_POSMType__c) && String.isNotBlank(requestModel.EURTRPOSMRecord.EUR_TR_RelatedPOSMSubType__c) && POSMSubTypeDefinition.EUR_TR_IsCarpenterPOSMType__c && requestModel.isVendorEmailFieldsControlRequired
                && (String.isBlank(requestModel.vendorEmailAddress) || String.isBlank(requestModel.emailBody)) && requestModel.EURTRPOSMApprovalRecord.EUR_TR_ApprovalProcessType__c.equalsIgnoreCase('Onay Talebi')) {
            throw new EUR_TR_POSMApprovalControllerException('Tedarikçi email adres bilgisi ve mesajı boş bırakılamaz');
        } else if (String.isBlank(requestModel.EURTRPOSMApprovalRecord.Id)) {
            throw new EUR_TR_POSMApprovalControllerException('Onay kaydı bilgisi boş gönderilemez');
        }

        EUR_TR_Approval__c approval = requestModel.EURTRPOSMApprovalRecord;
        EUR_TR_POSM__c POSMRecord = requestModel.EURTRPOSMRecord;

        if (approval.EUR_TR_ApprovalStatus__c.equalsIgnoreCase(PENDING) && approval.EUR_TR_ApprovalProcessType__c.equalsIgnoreCase('Onay Talebi')) {

            approval.EUR_TR_ApprovalStatus__c = APPROVED;
            approval.EUR_TR_ApproverComments__c = requestModel.approverComment;
            update approval;
            insertPOSMApprovalRecordHistory(approval);

            POSMRecord.EUR_TR_ApprovalStatus__c = APPROVED;
            update POSMRecord;
            successMessage = 'Onay talebiniz tamamlandı.POSM kaydınız onaylandı.';
            EUR_TR_POSMApprovalNotificationHelper.sendNotificationByPOSMApprovalRecord(approval, null);

            if (POSMSubTypeDefinition.EUR_TR_IsCarpenterPOSMType__c && requestModel.isVendorEmailFieldsControlRequired) {
                sendEmailToVendor(requestModel.vendorEmailAddress, requestModel.emailBody);
            }

        } else if (approval.EUR_TR_ApprovalStatus__c.equalsIgnoreCase(PENDING) && approval.EUR_TR_ApprovalProcessType__c.equalsIgnoreCase('İptal Talebi')) {

            approval.EUR_TR_ApprovalStatus__c = APPROVED;
            approval.EUR_TR_ApproverComments__c = requestModel.approverComment;
            update approval;
            insertPOSMApprovalRecordHistory(approval);

            POSMRecord.EUR_TR_ApprovalStatus__c = CANCELED;
            update POSMRecord;
            successMessage = 'İptal talebiniz onaylandı.';
            EUR_TR_POSMApprovalNotificationHelper.sendNotificationByPOSMApprovalRecord(approval, null);

            if (POSMSubTypeDefinition.EUR_TR_IsCarpenterPOSMType__c && requestModel.isVendorEmailFieldsControlRequired) {
                sendEmailToVendor(requestModel.vendorEmailAddress, requestModel.emailBody);
            }

        } else if (approval.EUR_TR_ApprovalStatus__c.equalsIgnoreCase(PENDING) && approval.EUR_TR_ApprovalProcessType__c.equalsIgnoreCase('Revize Talebi')) {

            Boolean isApprovalNotification = false;
            checkPOSMRecordIsValidByDefinition(requestModel, POSMSubTypeDefinition);
            Decimal unitPrice = null;
            if (POSMSubTypeDefinition.EUR_TR_UnitPrice__c != null) {
                requestModel.EURTRPOSMRecord.EUR_TR_Budget__c = POSMSubTypeDefinition.EUR_TR_UnitPrice__c * requestModel.EURTRPOSMRecord.EUR_TR_POSMQuantity__c;
                unitPrice = POSMSubTypeDefinition.EUR_TR_UnitPrice__c;
            }
            if (isApprovalProcessRequiredByBudgetDefinition(requestModel, POSMSubTypeDefinition)) {

                setApprovalFieldsByBudgetDefinition(requestModel, POSMSubTypeDefinition);
                POSMRecord = requestModel.EURTRPOSMRecord;
                approval = requestModel.EURTRPOSMApprovalRecord;
                update approval;
                Id posmApprovalHistoryId = insertPOSMApprovalRecordHistory(approval);
                POSMRecord.EUR_TR_UnitPrice__c = unitPrice;
                insertPOSMRecordHistory(POSMRecord, posmApprovalHistoryId);
                update POSMRecord;

                successMessage = 'Revize talebiniz onaya gönderilmiştir.';
                submitterNotificationMessage = successMessage;
                approverNotificationMessage = 'Revize talebi için onayınız beklenmektedir.';
                isApprovalNotification = true;

            } else if (isApprovalProcessRequiredByPOSMTypeDefinition(requestModel, POSMSubTypeDefinition)) {

                setApprovalFieldsByPOSMTypeDefinition(requestModel, POSMSubTypeDefinition);
                POSMRecord = requestModel.EURTRPOSMRecord;
                approval = requestModel.EURTRPOSMApprovalRecord;
                update approval;
                Id posmApprovalHistoryId = insertPOSMApprovalRecordHistory(approval);
                POSMRecord.EUR_TR_UnitPrice__c = unitPrice;
                insertPOSMRecordHistory(POSMRecord, posmApprovalHistoryId);
                update POSMRecord;

                successMessage = 'Revize talebiniz onaya gönderilmiştir.';
                submitterNotificationMessage = successMessage;
                approverNotificationMessage = 'Revize talebi için onayınız beklenmektedir.';
                isApprovalNotification = true;

            } else {

                // approval process is not required
                approval.EUR_TR_ApprovalStatus__c = APPROVED;
                approval.EUR_TR_ApproverComments__c = requestModel.approverComment;
                update approval;
                Id posmApprovalHistoryId = insertPOSMApprovalRecordHistory(approval);
                POSMRecord.EUR_TR_UnitPrice__c = unitPrice;
                insertPOSMRecordHistory(POSMRecord, posmApprovalHistoryId);
                POSMRecord.EUR_TR_ApprovalStatus__c = APPROVED;
                update POSMRecord;

                successMessage = 'Revize talebiniz onaylandı.';
                submitterNotificationMessage = successMessage;
                isApprovalNotification = false;

            }

            if (isApprovalNotification) {
                Boolean isSentEmailSuccessfully = sendApprovalEmail(approval);
                EUR_TR_POSMApprovalNotificationHelper.sendNotificationByPOSMApprovalRecord(approval, isSentEmailSuccessfully);
            } else {
                EUR_TR_POSMApprovalNotificationHelper.sendNotificationByPOSMRecord(POSMRecord, submitterNotificationMessage);
            }


        }

    }

    private static void handleCancelAction(POSMApprovalRequestModel requestModel) {

        EUR_TR_POSM__c POSMRecord = requestModel.EURTRPOSMRecord;

        EUR_TR_POSMDefinitionController.POSMSubTypeRequestModel POSMSubTypeRequestModel = new EUR_TR_POSMDefinitionController.POSMSubTypeRequestModel(requestModel.EURTRPOSMRecord);
        Map<String, EUR_TR_Definition__c> POSMSubTypeDefinitionMap = EUR_TR_POSMDefinitionController.getPOSMSubTypeDefinitionMap(POSMSubTypeRequestModel);
        System.debug(JSON.serializePretty(POSMSubTypeDefinitionMap));
        if (!POSMSubTypeDefinitionMap.containsKey(requestModel.EURTRPOSMRecord.EUR_TR_RelatedPOSMSubType__c)) {
            // TODO:iptal süreci için burası kontrol edilecek!!
            throw new EUR_TR_POSMApprovalControllerException('Geçersiz ürün alt tipi,seçilen ürün alt tipi ile ilgili tanım bulunamadı. Lütfen ürün alt tipini değiştirip yeniden deneyiniz.');
        }
        EUR_TR_Definition__c POSMSubTypeDefinition = POSMSubTypeDefinitionMap.get(requestModel.EURTRPOSMRecord.EUR_TR_RelatedPOSMSubType__c);


        if ((requestModel.EURTRPOSMApprovalRecord == null || String.isBlank(requestModel.EURTRPOSMApprovalRecord.Id)) && POSMRecord != null) {

            if (POSMRecord.EUR_TR_ApprovalStatus__c == APPROVED) {
                POSMRecord.EUR_TR_ApprovalStatus__c = CANCELED;
                update POSMRecord;
                successMessage = 'İptal işleminiz tamamlandı.POSM kaydınız iptal edilmiştir.';
            } else {
                throw new EUR_TR_POSMApprovalControllerException('İptal işlemi yanlızca onaylı kayıtlar için geçerlidir');
            }

        } else if ((requestModel.EURTRPOSMApprovalRecord != null || String.isNotBlank(requestModel.EURTRPOSMApprovalRecord.Id))) {

            EUR_TR_Approval__c approval = requestModel.EURTRPOSMApprovalRecord;

            if (approval.EUR_TR_Approver__c == UserInfo.getUserId()) {

                if (approval.EUR_TR_ApprovalProcessType__c == 'İptal Talebi') {
                    approval.EUR_TR_ApprovalStatus__c = APPROVED;
                    approval.EUR_TR_ApproverComments__c = requestModel.approverComment;
                }

                if (approval.EUR_TR_ApprovalProcessType__c == 'Onay Talebi') {
                    approval.EUR_TR_ApprovalStatus__c = CANCELED;
                    approval.EUR_TR_ApproverComments__c = requestModel.approverComment;
                }

                update approval;

                POSMRecord.EUR_TR_ApprovalStatus__c = CANCELED;
                update POSMRecord;
                insertPOSMApprovalRecordHistory(approval);

                successMessage = 'İptal talebiniz tamamlandı.POSM kaydınız iptal edilmiştir.';
                submitterNotificationMessage = successMessage;
                EUR_TR_POSMApprovalNotificationHelper.sendNotificationByPOSMRecord(POSMRecord, submitterNotificationMessage);
                if (POSMSubTypeDefinition.EUR_TR_IsCarpenterPOSMType__c && requestModel.isVendorEmailFieldsControlRequired) {
                    sendEmailToVendor(requestModel.vendorEmailAddress, requestModel.emailBody);
                }

            } else if (approval.EUR_TR_Submitter__c == UserInfo.getUserId()) {

                if (POSMSubTypeDefinition.EUR_TR_IsApprovalProcessRequiredToCancel__c && (isApprovalProcessRequiredByBudgetDefinition(requestModel, POSMSubTypeDefinition) || isApprovalProcessRequiredByPOSMTypeDefinition(requestModel, POSMSubTypeDefinition))) {

                    approval.EUR_TR_ApprovalProcessType__c = 'İptal Talebi';
                    approval.EUR_TR_ApprovalStatus__c = PENDING;
                    approval.EUR_TR_ApproverComments__c = requestModel.approverComment;
                    update approval;

                    POSMRecord.EUR_TR_ApprovalStatus__c = PENDING;
                    update POSMRecord;

                    successMessage = 'İptal talebiniz onaya gönderilmiştir.';
                    insertPOSMApprovalRecordHistory(approval);
                    Boolean isSentEmailSuccessfully = sendApprovalEmail(approval);
                    EUR_TR_POSMApprovalNotificationHelper.sendNotificationByPOSMApprovalRecord(approval, isSentEmailSuccessfully);

                } else {

                    // If the approval process is not required , the submitter can cancel the approval record.
                    approval.EUR_TR_ApprovalStatus__c = CANCELED;
                    approval.EUR_TR_ApproverComments__c = requestModel.approverComment;
                    update approval;
                    insertPOSMApprovalRecordHistory(approval);

                    POSMRecord.EUR_TR_ApprovalStatus__c = CANCELED;
                    update POSMRecord;
                    successMessage = 'İptal talebiniz tamamlandı.POSM kaydınız iptal edilmiştir.';
                    submitterNotificationMessage = successMessage;
                    EUR_TR_POSMApprovalNotificationHelper.sendNotificationByPOSMRecord(POSMRecord, submitterNotificationMessage);

                    if (POSMSubTypeDefinition.EUR_TR_IsCarpenterPOSMType__c && requestModel.isVendorEmailFieldsControlRequired) {
                        sendEmailToVendor(requestModel.vendorEmailAddress, requestModel.emailBody);
                    }
                }


            } else {
                throw new EUR_TR_POSMApprovalControllerException('Bu işlemi yapmaya yetkiniz bulunmamaktadır');
            }
        } else {
            throw new EUR_TR_POSMApprovalControllerException('Tanımlanmayan işlem.Lütfen sistem yöneticiniz ile iletişime geçiniz.');
        }


    }


    private static void handleRejectAction(POSMApprovalRequestModel requestModel) {

        EUR_TR_Approval__c approval = requestModel.EURTRPOSMApprovalRecord;
        EUR_TR_POSM__c POSMRecord = requestModel.EURTRPOSMRecord;

        if (approval.EUR_TR_ApprovalProcessType__c.equalsIgnoreCase('Revize Talebi') && approval.EUR_TR_ApprovalStatus__c.equalsIgnoreCase(PENDING)) {

            approval.EUR_TR_ApprovalStatus__c = REJECTED;
            approval.EUR_TR_ApproverComments__c = requestModel.approverComment;
            update approval;
            insertPOSMApprovalRecordHistory(approval);
            POSMRecord.EUR_TR_ApprovalStatus__c = REJECTED;
            update POSMRecord;

            successMessage = 'Revize talebiniz tamamlandı.POSM kaydınız rededilmiştir.';

        } else if (approval.EUR_TR_ApprovalProcessType__c.equalsIgnoreCase('İptal Talebi') && approval.EUR_TR_ApprovalStatus__c.equalsIgnoreCase(PENDING)) {

            approval.EUR_TR_ApprovalStatus__c = REJECTED;
            approval.EUR_TR_ApproverComments__c = requestModel.approverComment;
            update approval;
            insertPOSMApprovalRecordHistory(approval);

            POSMRecord.EUR_TR_ApprovalStatus__c = APPROVED;
            update POSMRecord;

            successMessage = 'İptal talebiniz reddedilmiştir.';

        } else if (approval.EUR_TR_ApprovalProcessType__c.equalsIgnoreCase('Onay Talebi') && approval.EUR_TR_ApprovalStatus__c.equalsIgnoreCase(PENDING)) {

            approval.EUR_TR_ApprovalStatus__c = REJECTED;
            approval.EUR_TR_ApproverComments__c = requestModel.approverComment;
            update approval;
            insertPOSMApprovalRecordHistory(approval);
            POSMRecord.EUR_TR_ApprovalStatus__c = REJECTED;
            update POSMRecord;

            successMessage = 'Onay talebiniz tamamlandı.POSM kaydınız rededilmiştir.';

        }

        EUR_TR_POSMApprovalNotificationHelper.sendNotificationByPOSMApprovalRecord(approval, null);

    }

    private static void handleReviseAction(POSMApprovalRequestModel requestModel) {

        EUR_TR_Approval__c approval = requestModel.EURTRPOSMApprovalRecord;

        approval.EUR_TR_ApprovalStatus__c = PENDING;
        approval.EUR_TR_ApprovalProcessType__c = 'Revize Talebi';
        approval.EUR_TR_ApproverComments__c = requestModel.approverComment;
        Id submitter = approval.EUR_TR_Submitter__c;
        approval.EUR_TR_Submitter__c = approval.EUR_TR_Approver__c;
        approval.EUR_TR_Approver__c = submitter;
        update approval;
        insertPOSMApprovalRecordHistory(approval);

        successMessage = 'Talep temsilciye revize talebi olarak geri gönderilmiştir.';
        submitterNotificationMessage = successMessage;
        approverNotificationMessage = 'Revize talebi onayınız beklemektedir.';

        Boolean isSentEmailSuccessfully = sendApprovalEmail(approval);
        EUR_TR_POSMApprovalNotificationHelper.sendNotificationByPOSMApprovalRecord(approval, isSentEmailSuccessfully);

    }

    private static Boolean isApprovalProcessRequiredByBudgetDefinition(POSMApprovalRequestModel request, EUR_TR_Definition__c POSMSubTypeDefinition) {

        Boolean isApprovalProcessRequiredByBudgetDefinition = false;
        // Budget Approval
        if (request.EURTRPOSMRecord.EUR_TR_Budget__c > POSMSubTypeDefinition.EUR_TR_Budget__c) {
            isApprovalProcessRequiredByBudgetDefinition = true;
        }
        return isApprovalProcessRequiredByBudgetDefinition;
    }

    private static Boolean isApprovalProcessRequiredByPOSMTypeDefinition(POSMApprovalRequestModel request, EUR_TR_Definition__c POSMSubTypeDefinition) {
        Boolean isApprovalProcessRequiredByPOSMTypeDefinition = false;

        if (POSMSubTypeDefinition.EUR_TR_ApprovalProcessIsRequired__c) {
            isApprovalProcessRequiredByPOSMTypeDefinition = true;
        }
        return isApprovalProcessRequiredByPOSMTypeDefinition;
    }

    private static void setApprovalFieldsByPOSMTypeDefinition(POSMApprovalRequestModel request, EUR_TR_Definition__c POSMSubTypeDefinition) {

        EUR_TR_POSM__c POSMRecord = request.EURTRPOSMRecord;

        if (POSMSubTypeDefinition.EUR_TR_ApprovalProcessIsRequired__c) {
            // will be created approval process
            POSMRecord.EUR_TR_ApprovalStatus__c = PENDING;
            preparePOSMApprovalRecord(POSMSubTypeDefinition, request.EURTRPOSMApprovalRecord, POSMRecord, 'Onay Talebi', 'Ürün');
        } else {
            // will be created record directly without any approval process
            if (String.isNotBlank(request.EURTRPOSMRecord.EUR_TR_POSMType__c) && String.isNotBlank(request.EURTRPOSMRecord.EUR_TR_RelatedPOSMSubType__c) && POSMSubTypeDefinition.EUR_TR_IsCarpenterPOSMType__c
                    && (String.isBlank(request.vendorEmailAddress) || String.isBlank(request.emailBody))) {
                throw new EUR_TR_POSMApprovalControllerException('Tedarikçi email adres bilgisi ve mesajı boş bırakılamaz');
            }
            POSMRecord.EUR_TR_ApprovalStatus__c = APPROVED;
        }
        request.EURTRPOSMRecord = POSMRecord;
    }

    private static void setApprovalFieldsByBudgetDefinition(POSMApprovalRequestModel request, EUR_TR_Definition__c POSMSubTypeDefinition) {

        EUR_TR_POSM__c POSMRecord = request.EURTRPOSMRecord;

        if (request.EURTRPOSMRecord.EUR_TR_Budget__c > POSMSubTypeDefinition.EUR_TR_Budget__c) {
            // will be created approval process
            POSMRecord.EUR_TR_ApprovalStatus__c = PENDING;
            preparePOSMApprovalRecord(POSMSubTypeDefinition, request.EURTRPOSMApprovalRecord, request.EURTRPOSMRecord, 'Onay Talebi', 'Bütçe');
        }
        request.EURTRPOSMRecord = POSMRecord;
    }


    private static void preparePOSMApprovalRecord(EUR_TR_Definition__c POSMTypeDefinition, EUR_TR_Approval__c approval, EUR_TR_POSM__c POSMRecord, String approvalProcessType, String approvalReason) {

        EUR_TR_Account__c account = [
                SELECT
                        Id,
                        Name,
                        EUR_TR_TopExManagerName__c,
                        EUR_TR_ChannelManagerName__c,
                        EUR_TR_AreaManagerName__c,
                        EUR_TR_SalesChiefName__c,
                        EUR_TR_PresellerName__c
                FROM EUR_TR_Account__c
                WHERE Id = :POSMRecord.EUR_TR_RelatedAccount__c
        ];

        approval.Name = String.format('{0} Talebi', new List<String>{
                POSMRecord.EUR_TR_POSMType__c
        });
        approval.OwnerId = UserInfo.getUserId();
        approval.EUR_TR_RelatedPOSM__c = POSMRecord.Id;
        approval.EUR_TR_Submitter__c = UserInfo.getUserId();
        approval.EUR_TR_Approver__c = getApproverByPOSMDefinition(POSMTypeDefinition, account);
        approval.RecordTypeId = Schema.SObjectType.EUR_TR_Approval__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMApproval').getRecordTypeId();
        approval.EUR_TR_ApprovalProcessType__c = approvalProcessType;
        approval.EUR_TR_ApprovalReason__c = approvalReason;
        approval.EUR_TR_ApprovalStatus__c = PENDING;
        approval.EUR_TR_ApprovalDescription__c = String.format('{0} {1} {2}', new List<String>{
                account.Name,
                POSMRecord.EUR_TR_POSMType__c,
                approvalProcessType
        });

    }

    private static Id insertPOSMApprovalRecordHistory(EUR_TR_Approval__c eurtrposmApproval) {

        EUR_TR_Approval__c approval = new EUR_TR_Approval__c();
        approval.Name = String.format('{0} {1}', new List<String>{
                'Talep Geçmişi', Datetime.now().format()
        });
        approval.OwnerId = UserInfo.getUserId();
        approval.EUR_TR_RelatedApproval__c = eurtrposmApproval.Id;
        approval.EUR_TR_Submitter__c = eurtrposmApproval.EUR_TR_Submitter__c;
        approval.EUR_TR_Approver__c = eurtrposmApproval.EUR_TR_Approver__c;
        approval.RecordTypeId = Schema.SObjectType.EUR_TR_Approval__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMApprovalHistory').getRecordTypeId();
        approval.EUR_TR_ApprovalProcessType__c = eurtrposmApproval.EUR_TR_ApprovalProcessType__c;
        approval.EUR_TR_ApprovalStatus__c = eurtrposmApproval.EUR_TR_ApprovalStatus__c;

        insert approval;

        return approval.Id;

    }

    private static void insertPOSMRecordHistory(EUR_TR_POSM__c newPOSMRecord, Id relatedApprovalHistoryId) {

        if (newPOSMRecord.Id == null) {
            throw new EUR_TR_POSMApprovalControllerException('Revize talebinde POSM boş gönderilemez.');
        }

        EUR_TR_POSM__c oldPOSMRecord = [
                SELECT Id,EUR_TR_POSMQuantity__c,EUR_TR_POSMType__c,EUR_TR_Budget__c,
                        EUR_TR_Brand__c,EUR_TR_BrandOther__c,EUR_TR_PlacementDate__c,EUR_TR_RelatedAccount__c,EUR_TR_UnitPrice__c,
                        EUR_TR_RelatedPOSMSubType__c,
                        EUR_TR_RelatedPOSMSubType__r.Name
                FROM EUR_TR_POSM__c
                WHERE Id = :newPOSMRecord.Id
        ];

        List<EUR_TR_POSM__c> POSMHistories = new List<EUR_TR_POSM__c>();
        EUR_TR_POSM__c POSMHistory = new EUR_TR_POSM__c();
        Id POSMHistoryRecordTypeId = Schema.SObjectType.EUR_TR_POSM__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMHistory').getRecordTypeId();

        if (oldPOSMRecord.EUR_TR_POSMQuantity__c != newPOSMRecord.EUR_TR_POSMQuantity__c) {
            POSMHistory = createPOSMHistoryInstance(POSMHistoryRecordTypeId, newPOSMRecord.Id, relatedApprovalHistoryId, 'EUR_TR_POSMQuantity__c', String.valueOf(oldPOSMRecord.EUR_TR_POSMQuantity__c), String.valueOf(newPOSMRecord.EUR_TR_POSMQuantity__c));
            POSMHistories.add(POSMHistory);
        }

        if (oldPOSMRecord.EUR_TR_Budget__c != newPOSMRecord.EUR_TR_Budget__c) {
            POSMHistory = createPOSMHistoryInstance(POSMHistoryRecordTypeId, newPOSMRecord.Id, relatedApprovalHistoryId, 'EUR_TR_Budget__c', String.valueOf(oldPOSMRecord.EUR_TR_Budget__c), String.valueOf(newPOSMRecord.EUR_TR_Budget__c));
            POSMHistories.add(POSMHistory);
        }

        if (oldPOSMRecord.EUR_TR_Brand__c != newPOSMRecord.EUR_TR_Brand__c) {
            POSMHistory = createPOSMHistoryInstance(POSMHistoryRecordTypeId, newPOSMRecord.Id, relatedApprovalHistoryId, 'EUR_TR_Brand__c', String.valueOf(oldPOSMRecord.EUR_TR_Brand__c), String.valueOf(newPOSMRecord.EUR_TR_Brand__c));
            POSMHistories.add(POSMHistory);
        }

        if (oldPOSMRecord.EUR_TR_BrandOther__c != newPOSMRecord.EUR_TR_BrandOther__c) {
            POSMHistory = createPOSMHistoryInstance(POSMHistoryRecordTypeId, newPOSMRecord.Id, relatedApprovalHistoryId, 'EUR_TR_BrandOther__c', String.valueOf(oldPOSMRecord.EUR_TR_BrandOther__c), String.valueOf(newPOSMRecord.EUR_TR_BrandOther__c));
            POSMHistories.add(POSMHistory);
        }

        if (oldPOSMRecord.EUR_TR_PlacementDate__c != newPOSMRecord.EUR_TR_PlacementDate__c) {
            POSMHistory = createPOSMHistoryInstance(POSMHistoryRecordTypeId, newPOSMRecord.Id, relatedApprovalHistoryId, 'EUR_TR_PlacementDate__c', String.valueOf(oldPOSMRecord.EUR_TR_PlacementDate__c), String.valueOf(newPOSMRecord.EUR_TR_PlacementDate__c));
            POSMHistories.add(POSMHistory);
        }

        if (oldPOSMRecord.EUR_TR_POSMType__c != newPOSMRecord.EUR_TR_POSMType__c) {
            POSMHistory = createPOSMHistoryInstance(POSMHistoryRecordTypeId, newPOSMRecord.Id, relatedApprovalHistoryId, 'EUR_TR_POSMType__c', String.valueOf(oldPOSMRecord.EUR_TR_POSMType__c), String.valueOf(newPOSMRecord.EUR_TR_POSMType__c));
            POSMHistories.add(POSMHistory);
        }

        if (oldPOSMRecord.EUR_TR_UnitPrice__c != newPOSMRecord.EUR_TR_UnitPrice__c) {
            POSMHistory = createPOSMHistoryInstance(POSMHistoryRecordTypeId, newPOSMRecord.Id, relatedApprovalHistoryId, 'EUR_TR_UnitPrice__c', String.valueOf(oldPOSMRecord.EUR_TR_UnitPrice__c), String.valueOf(newPOSMRecord.EUR_TR_UnitPrice__c));
            POSMHistories.add(POSMHistory);
        }

        if (oldPOSMRecord.EUR_TR_RelatedPOSMSubType__c != newPOSMRecord.EUR_TR_RelatedPOSMSubType__c) {

            EUR_TR_Definition__c newPOSMRecordRelatedPOSMSubTypeDefinition = [
                    SELECT Id,Name,EUR_TR_UnitPrice__c
                    FROM EUR_TR_Definition__c
                    WHERE Id = :newPOSMRecord.EUR_TR_RelatedPOSMSubType__c AND RecordType.DeveloperName = 'EUR_TR_POSMType'
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];
            if (oldPOSMRecord.EUR_TR_RelatedPOSMSubType__r.Name != newPOSMRecordRelatedPOSMSubTypeDefinition.Name) {
                POSMHistory = createPOSMHistoryInstance(POSMHistoryRecordTypeId, newPOSMRecord.Id, relatedApprovalHistoryId, 'EUR_TR_RelatedPOSMSubType__c', String.valueOf(oldPOSMRecord.EUR_TR_RelatedPOSMSubType__r.Name), String.valueOf(newPOSMRecordRelatedPOSMSubTypeDefinition.Name));
                POSMHistories.add(POSMHistory);
            }
        }

        if (!POSMHistories.isEmpty()) {
            insert POSMHistories;
        }


    }

    private static EUR_TR_POSM__c createPOSMHistoryInstance(Id POSMHistoryRecordTypeId, Id relatedPOSMId, Id relatedApprovalHistoryId, String fieldName, String oldValue, String newValue) {

        EUR_TR_POSM__c POSMHistory = new EUR_TR_POSM__c();
        POSMHistory.RecordTypeId = POSMHistoryRecordTypeId;
        POSMHistory.EUR_TR_RelatedPOSM__c = relatedPOSMId;
        POSMHistory.EUR_TR_RelatedPOSMApprovalHistory__c = relatedApprovalHistoryId;
        POSMHistory.EUR_TR_ChangedFieldName__c = fieldName;
        POSMHistory.EUR_TR_FieldOldValue__c = oldValue;
        POSMHistory.EUR_TR_FieldNewValue__c = newValue;
        return POSMHistory;

    }

    @TestVisible
    private static Id getApproverByPOSMDefinition(EUR_TR_Definition__c POSMTypeDefinition, EUR_TR_Account__c account) {


        List<EUR_TR_Employee__c> employees = null;

        if (String.isBlank(POSMTypeDefinition.EUR_TR_ApproverTitle__c)) {
            throw new EUR_TR_POSMApprovalControllerException('Onay işlemi için ürün bazlı pozisyon tanımı bulunamadı.Lütfen sistem yöneticiniz ile iletişime geçiniz');
        } else if (!(POSMTypeDefinition.EUR_TR_ApproverTitle__c.equalsIgnoreCase('Kanal Müdürü') || POSMTypeDefinition.EUR_TR_ApproverTitle__c.equalsIgnoreCase('TopEx Müdürü') || POSMTypeDefinition.EUR_TR_ApproverTitle__c.equalsIgnoreCase('Bölge Müdürü'))) {
            throw new EUR_TR_POSMApprovalControllerException('Tanımlanan onaycı pozisyonu bulunamadı.Lütfen sistem yönecisi ile iletişime geçiniz');
        }


        if (POSMTypeDefinition.EUR_TR_ApproverTitle__c.equalsIgnoreCase('Kanal Müdürü')) {

            if (String.isBlank(account.EUR_TR_ChannelManagerName__c)) {
                throw new EUR_TR_POSMApprovalControllerException('Nokta üzerinde Kanal Müdürü bulunamadı.Lütfen sistem yöneticisi ile iletişime geçiniz.');
            }
            employees = [
                    SELECT Id,EUR_TR_RelatedUser__c
                    FROM EUR_TR_Employee__c
                    WHERE Name = :account.EUR_TR_ChannelManagerName__c
                    LIMIT 1
            ];

        } else if (POSMTypeDefinition.EUR_TR_ApproverTitle__c.equalsIgnoreCase('TopEx Müdürü')) {

            if (String.isBlank(account.EUR_TR_TopExManagerName__c)) {
                throw new EUR_TR_POSMApprovalControllerException('Nokta üzerinde TopEx müdürü bulunamadı.Lütfen sistem yöneticisi ile iletişime geçiniz.');
            }
            employees = [
                    SELECT Id,EUR_TR_RelatedUser__c
                    FROM EUR_TR_Employee__c
                    WHERE Name = :account.EUR_TR_TopExManagerName__c
                    LIMIT 1
            ];

        } else if (POSMTypeDefinition.EUR_TR_ApproverTitle__c.equalsIgnoreCase('Bölge Müdürü')) {

            if (String.isBlank(account.EUR_TR_AreaManagerName__c)) {
                throw new EUR_TR_POSMApprovalControllerException('Nokta üzerinde bölge müdürü bulunamadı.Lütfen sistem yöneticisi ile iletişime geçiniz.');
            }
            employees = [
                    SELECT Id,EUR_TR_RelatedUser__c
                    FROM EUR_TR_Employee__c
                    WHERE Name = :account.EUR_TR_AreaManagerName__c
                    LIMIT 1
            ];

        }

        if (employees.isEmpty()) {
            throw new EUR_TR_POSMApprovalControllerException(String.format('Noktanın ilgili {0} kullanıcısı bulunamadı.Lütfen sistem yöneticisi ile iletişime geçiniz.', new List<String>{
                    POSMTypeDefinition.EUR_TR_ApproverTitle__c
            }));
        } else if (String.isBlank(employees.get(0).EUR_TR_RelatedUser__c)) {
            throw new EUR_TR_POSMApprovalControllerException(String.format('Noktanın ilgili {0} kullanıcısı bulunamadı.Lütfen sistem yöneticisi ile iletişime geçiniz.', new List<String>{
                    POSMTypeDefinition.EUR_TR_ApproverTitle__c
            }));
        } else {
            return employees.get(0).EUR_TR_RelatedUser__c;
        }

    }

    public static POSMApprovalResult getPOSMApprovalRecords(POSMApprovalFilterModel approvalFilterModel) {

        if (approvalFilterModel == null) {
            throw new EUR_TR_POSMApprovalControllerException('Filtre boş gönderilemez');
        } else if (approvalFilterModel.pageSize == null && approvalFilterModel.pageNumber == null) {
            throw new EUR_TR_POSMApprovalControllerException('Kayıt sayısı ve sayfa numarası boş gönderilemez');
        }

        Id currentUserId = UserInfo.getUserId();
        Integer offset = approvalFilterModel.pageSize * (approvalFilterModel.pageNumber - 1);
        Integer rowLimit = approvalFilterModel.pageSize;

        String querySelect = '' +
                'SELECT Id,Name' +
                ',EUR_TR_ApprovalProcessType__c,EUR_TR_ApprovalStatus__c' +
                ',EUR_TR_ApprovalReason__c' +
                ',EUR_TR_Approver__r.Name' +
                ',EUR_TR_Submitter__r.Name' +
                ',EUR_TR_RelatedPOSM__c' +
                ',EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__c' +
                ',EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__r.Name' +
                ',EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__r.EUR_TR_UnitPrice__c' +
                ',EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__r.EUR_TR_POSMTypeStatus__c' +
                ',EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__r.EUR_TR_IsCarpenterPOSMType__c' +
                ',CreatedDate ';

        String queryFrom = 'FROM EUR_TR_Approval__c ';
        String queryWhere = 'WHERE RecordType.DeveloperName=\'EUR_TR_POSMApproval\' AND  ( EUR_TR_Approver__c = :currentUserId OR EUR_TR_Submitter__c = :currentUserId ) ';

        if (String.isNotBlank(approvalFilterModel.approvalId)) {
            Id approvalId = approvalFilterModel.approvalId;
            queryWhere += 'AND Id=:approvalId ';
        }

        if (approvalFilterModel.POSMTypes != null && !approvalFilterModel.POSMTypes.isEmpty()) {
            List<String> POSMTypes = approvalFilterModel.POSMTypes;
            if (POSMTypes != null && !POSMTypes.isEmpty()) {
                queryWhere += 'AND EUR_TR_RelatedPOSM__r.EUR_TR_POSMType__c  IN:POSMTypes ';
            }
        }

        if (approvalFilterModel.POSMSubTypes != null && !approvalFilterModel.POSMSubTypes.isEmpty()) {
            List<String> POSMSubTypes = approvalFilterModel.POSMSubTypes;
            if (POSMSubTypes != null && !POSMSubTypes.isEmpty()) {
                queryWhere += 'AND EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__r.Name  IN:POSMSubTypes ';
            }
        }

        if (approvalFilterModel.approvalStatuses != null && !approvalFilterModel.approvalStatuses.isEmpty()) {
            List<String> approvalStatus = approvalFilterModel.approvalStatuses;
            if (approvalStatus != null && !approvalStatus.isEmpty()) {
                queryWhere += 'AND EUR_TR_ApprovalStatus__c  IN:approvalStatus ';
            }
        }

        if (approvalFilterModel.brands != null && !approvalFilterModel.brands.isEmpty()) {
            List<String> brands = approvalFilterModel.brands;
            if (brands != null && !brands.isEmpty()) {
                queryWhere += 'AND EUR_TR_RelatedPOSM__r.EUR_TR_Brand__c  IN:brands ';
            }
        }

        if (approvalFilterModel.approvalProcessTypes != null && !approvalFilterModel.approvalProcessTypes.isEmpty()) {
            List<String> approvalProcessTypes = approvalFilterModel.approvalProcessTypes;
            if (approvalProcessTypes != null && !approvalProcessTypes.isEmpty()) {
                queryWhere += 'AND EUR_TR_ApprovalProcessType__c  IN:approvalProcessTypes ';
            }
        }

        if (approvalFilterModel.minBudget != null) {
            Decimal minBudget = approvalFilterModel.minBudget;
            queryWhere += 'AND EUR_TR_RelatedPOSM__r.EUR_TR_Budget__c >=:minBudget ';
        }

        if (approvalFilterModel.maxBudget != null) {
            Decimal maxBudget = approvalFilterModel.maxBudget;
            queryWhere += 'AND EUR_TR_RelatedPOSM__r.EUR_TR_Budget__c <=:maxBudget ';
        }

        if (approvalFilterModel.actorIds != null && !approvalFilterModel.actorIds.isEmpty()) {
            List<Id> actorIds = approvalFilterModel.actorIds;
            queryWhere += 'AND ( EUR_TR_Approver__c in:actorIds OR EUR_TR_Submitter__C in:actorIds ) ';
        }

        if (approvalFilterModel.startDate != null) {
            Date starDate = approvalFilterModel.startDate;
            queryWhere += 'AND DAY_ONLY(convertTimezone(CreatedDate)) >= :starDate ';
        }

        if (approvalFilterModel.endDate != null) {
            Date endDate = approvalFilterModel.endDate;
            queryWhere += 'AND DAY_ONLY(convertTimezone(CreatedDate)) <= :endDate ';
        }

        String queryOrderDirection = approvalFilterModel.orderDirection == EUR_TR_POSMController.OrderDirection.ascending ? 'ASC' : 'DESC';
        String queryOrderBy = '';
        if (approvalFilterModel.orderBy == POSMApprovalOrderBy.createdDate) {
            queryOrderBy += 'ORDER BY CreatedDate ';
        } else if (approvalFilterModel.orderBy == POSMApprovalOrderBy.account) {
            queryOrderBy += 'ORDER BY EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__r.Name ';
        } else if (approvalFilterModel.orderBy == POSMApprovalOrderBy.approvalType) {
            queryOrderBy += 'ORDER BY EUR_TR_ApprovalProcessType__c ';
        } else if (approvalFilterModel.orderBy == POSMApprovalOrderBy.approvalStatus) {
            queryOrderBy += 'ORDER BY EUR_TR_ApprovalStatus__c ';
        } else {
            queryOrderBy += 'ORDER BY CreatedDate ';
        }


        String queryOffSetLimit = 'LIMIT :rowLimit OFFSET :offset ';

        String query = String.format('{0} {1} {2} {3} {4} {5} {6}', new List<String>{
                querySelect,
                queryFrom,
                queryWhere,
                queryOrderBy,
                queryOrderDirection,
                'NULLS LAST',
                queryOffsetLimit
        });

        String countQuery = String.format('SELECT COUNT(ID) Total FROM EUR_TR_Approval__c {0} ', new List<String>{
                queryWhere
        });

        System.debug(query);
        System.debug(countQuery);

        List<EUR_TR_Approval__c> approvals = Database.query(query);
        Integer totalRecordSize = Integer.valueOf(Database.query(countQuery).get(0).get('Total'));

        Set<Id> POSMRecordIDs = new Set<Id>();
        for (EUR_TR_Approval__c approval : approvals) {
            if (approval.EUR_TR_RelatedPOSM__c != null) {
                POSMRecordIDs.add(approval.EUR_TR_RelatedPOSM__c);
            }
        }


        Map<Id, EUR_TR_POSM__c> POSMRecordMap = new Map<Id, EUR_TR_POSM__c>([
                SELECT
                        Id,
                        Name,
                        EUR_TR_ApprovalStatus__c,
                        EUR_TR_Brand__c,
                        EUR_TR_BrandOther__c,
                        EUR_TR_Budget__c,
                        EUR_TR_PlacementDate__c,
                        EUR_TR_POSMType__c,
                        EUR_TR_RelatedAccount__c,
                        EUR_TR_RelatedAccount__r.Name,
                        EUR_TR_RelatedAccount__r.EUR_TR_AccountCode__c,
                        EUR_TR_POSMQuantity__c,
                        CreatedDate,
                        EUR_TR_UnitPrice__c,
                        OwnerId,
                        Owner.Name,
                        EUR_TR_RelatedPOSMSubType__c,
                        EUR_TR_RelatedPOSMSubType__r.Name,
                        EUR_TR_RelatedPOSMSubType__r.EUR_TR_UnitPrice__c,
                        EUR_TR_RelatedPOSMSubType__r.EUR_TR_POSMTypeStatus__c,
                        EUR_TR_RelatedPOSMSubType__r.EUR_TR_IsCarpenterPOSMType__c
                FROM EUR_TR_POSM__c
                WHERE Id IN :POSMRecordIDs
        ]);

        Set<String> relatedPOSMSubTypeDefinitionNames = new Set<String>();
        for (EUR_TR_POSM__c POSMRecord : POSMRecordMap.values()) {
            if (POSMRecord.EUR_TR_RelatedPOSMSubType__r.Name != null) {
                relatedPOSMSubTypeDefinitionNames.add(POSMRecord.EUR_TR_RelatedPOSMSubType__r.Name);
            }
        }
        Map<String, EUR_TR_Definition__c> activeRelatedPOSMSubTypeNameToDefinitionMap = new Map<String, EUR_TR_Definition__c>();
        for (EUR_TR_Definition__c definition : [
                SELECT Id,Name,EUR_TR_UnitPrice__c,EUR_TR_POSMType__c,EUR_TR_IsCarpenterPOSMType__c
                FROM EUR_TR_Definition__c
                WHERE Name = :relatedPOSMSubTypeDefinitionNames AND RecordType.DeveloperName = 'EUR_TR_POSMType' AND EUR_TR_POSMTypeStatus__c = 'Aktif'
        ]) {
            activeRelatedPOSMSubTypeNameToDefinitionMap.put(definition.Name, definition);
        }


        List<EUR_TR_POSMController.POSMWrapper> approvalResults = new List<EUR_TR_POSMController.POSMWrapper>();
        EUR_TR_POSMController.POSMWrapper approvalWrapper = null;

        for (EUR_TR_Approval__c approval : approvals) {
            approvalWrapper = new EUR_TR_POSMController.POSMWrapper();
            approvalWrapper.approval = approval;
            if (POSMRecordMap.containsKey(approval.EUR_TR_RelatedPOSM__c)) {
                approvalWrapper.POSMRecord = POSMRecordMap.get(approval.EUR_TR_RelatedPOSM__c);
            }
            if (approvalWrapper.POSMRecord.EUR_TR_RelatedPOSMSubType__r.EUR_TR_POSMTypeStatus__c != null && approvalWrapper.POSMRecord.EUR_TR_RelatedPOSMSubType__r.EUR_TR_POSMTypeStatus__c == 'Aktif') {
                approvalWrapper.activePOSMSubTypeDefinition = approvalWrapper.POSMRecord.EUR_TR_RelatedPOSMSubType__r;
            } else if (approvalWrapper.POSMRecord.EUR_TR_RelatedPOSMSubType__r.EUR_TR_POSMTypeStatus__c != null && approvalWrapper.POSMRecord.EUR_TR_RelatedPOSMSubType__r.EUR_TR_POSMTypeStatus__c == 'Pasif') {
                if (activeRelatedPOSMSubTypeNameToDefinitionMap != null && !activeRelatedPOSMSubTypeNameToDefinitionMap.isEmpty() && approvalWrapper.POSMRecord.EUR_TR_RelatedPOSMSubType__r.Name != null) {
                    if (activeRelatedPOSMSubTypeNameToDefinitionMap.containsKey(approvalWrapper.POSMRecord.EUR_TR_RelatedPOSMSubType__r.Name)) {
                        EUR_TR_Definition__c activeRelatedPOSMSubDefinition = activeRelatedPOSMSubTypeNameToDefinitionMap.get(approvalWrapper.POSMRecord.EUR_TR_RelatedPOSMSubType__r.Name);
                        approvalWrapper.activePOSMSubTypeDefinition = activeRelatedPOSMSubDefinition;
                    } else {
                        approvalWrapper.activePOSMSubTypeDefinition = null;
                    }
                }
            } else {
                approvalWrapper.activePOSMSubTypeDefinition = null;
            }
            approvalWrapper.actions = getActionsByPOSMApprovalRecord(approval);
            approvalResults.add(approvalWrapper);
        }

        POSMApprovalResult result = new POSMApprovalResult();
        result.records = approvalResults;
        result.totalRecordSize = totalRecordSize;

        return result;

    }

    public static EURTRPOSMApprovalHistoryWrapper getPOSMApprovalRecordHistory(EUR_TR_Approval__c approval) {

        if (approval == null) {
            throw new EUR_TR_POSMApprovalControllerException('Onay kaydı boş gönderilemez');
        } else if (approval.Id == null) {
            throw new EUR_TR_POSMApprovalControllerException('Onay kaydı boş gönderilemez');
        }

        approval = [
                SELECT
                        Id,
                        EUR_TR_RelatedPOSM__r.EUR_TR_POSMType__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__r.Name
                FROM EUR_TR_Approval__c
                WHERE Id = :approval.Id
        ];

        List<EUR_TR_Approval__c> posmApprovalHistories = [
                SELECT
                        Id,
                        CreatedDate,
                        CreatedBy.Id,
                        CreatedBy.Name,
                        EUR_TR_ApprovalProcessType__c,
                        EUR_TR_ApprovalStatus__c,
                        EUR_TR_ApproverComments__c, (
                        SELECT
                                id,
                                EUR_TR_ChangedFieldName__c,
                                EUR_TR_FieldOldValue__c,
                                EUR_TR_FieldNewValue__c
                        FROM EUR_TR_POSMChanges__r
                )
                FROM EUR_TR_Approval__c
                WHERE EUR_TR_RelatedApproval__c = :approval.Id
                ORDER BY CreatedDate DESC
        ];

        EURTRPOSMApprovalHistoryWrapper result = new EURTRPOSMApprovalHistoryWrapper();
        List<EURTRPOSMApprovalHistory> approvalHistories = new List<EURTRPOSMApprovalHistory>();
        EURTRPOSMApprovalHistory approvalHistory = null;

        for (EUR_TR_Approval__c app : posmApprovalHistories) {

            approvalHistory = new EURTRPOSMApprovalHistory();
            approvalHistory.actor = app.CreatedBy;
            approvalHistory.approverComments = app.EUR_TR_ApproverComments__c;
            approvalHistory.actionTime = app.CreatedDate;
            approvalHistory.approvalType = app.EUR_TR_ApprovalProcessType__c;

            List<FieldChangeModel> POSMChanges = new List<FieldChangeModel>();
            FieldChangeModel POSMChange = new FieldChangeModel();
            for (EUR_TR_POSM__c changedInfo : app.EUR_TR_POSMChanges__r) {
                POSMChange = new FieldChangeModel();
                POSMChange.oldValue = changedInfo.EUR_TR_FieldOldValue__c;
                POSMChange.newValue = changedInfo.EUR_TR_FieldNewValue__c;
                POSMChange.fieldLabel = Schema.getGlobalDescribe().get('EUR_TR_POSM__c').getDescribe().fields.getMap().get(changedInfo.EUR_TR_ChangedFieldName__c).getDescribe().getLabel();
                POSMChange.fieldName = changedInfo.EUR_TR_ChangedFieldName__c;
                POSMChanges.add(POSMChange);
            }
            approvalHistory.changes = POSMChanges;

            approvalHistory.approvalStatus = app.EUR_TR_ApprovalStatus__c;
            if (app.EUR_TR_ApprovalStatus__c == PENDING) {
                approvalHistory.approvalStatusLabel = 'Onaya Gönderildi';
            } else if (app.EUR_TR_ApprovalStatus__c == REJECTED) {
                approvalHistory.approvalStatusLabel = 'Reddedildi';
            } else if (app.EUR_TR_ApprovalStatus__c == APPROVED) {
                approvalHistory.approvalStatusLabel = 'Onaylandı';
            }

            approvalHistories.add(approvalHistory);

        }

        result.approvalHistories = approvalHistories;
        result.customerName = approval.EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__r.Name;
        result.POSMType = approval.EUR_TR_RelatedPOSM__r.EUR_TR_POSMType__c;

        return result;

    }

    public static List<ButtonAction> getActionsByPOSMApprovalRecord(EUR_TR_Approval__c approval) {

        List<ButtonAction> approvalActions = new List<ButtonAction>();
        if (approval.EUR_TR_ApprovalProcessType__c != null && approval.EUR_TR_ApprovalStatus__c != null) {
            if (approval.EUR_TR_Approver__c == UserInfo.getUserId()) {
                setApproverActions(approval, approvalActions);
            } else if (approval.EUR_TR_Submitter__c == UserInfo.getUserId()) {
                setSubmitterActions(approval, approvalActions);
            }
        }

        return approvalActions;
    }

    public static List<User> getApprovalActors(POSMApprovalFilterModel filterModel) {

        if (filterModel.relatedAccount == null) {
            return getAllMyPOSMApprovalActors();
        } else {
            return getActorsByRelatedAccount(filterModel.relatedAccount);
        }

    }

    public static List<EUR_TR_POSMDefinitionController.PicklistItem> getPOSMSubTypeFilterOptions(POSMApprovalFilterModel filterModel) {

        Set<String> POSMSubTypes = new Set<String>();

        if (filterModel.relatedAccount == null) {
            for (EUR_TR_Approval__c approval : [
                    SELECT Id,EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__r.Name
                    FROM EUR_TR_Approval__c
                    WHERE (EUR_TR_Approver__c = :UserInfo.getUserId() OR EUR_TR_Submitter__c = :UserInfo.getUserId()) AND RecordType.DeveloperName = 'EUR_TR_POSMApproval' AND EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__c != NULL
            ]) {
                if (!POSMSubTypes.contains(approval.EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__r.Name)) {
                    POSMSubTypes.add(approval.EUR_TR_RelatedPOSM__r.EUR_TR_RelatedPOSMSubType__r.Name);
                } else {
                    continue;
                }
            }
        } else {
            for (EUR_TR_POSM__c POSMRecord : [
                    SELECT Id,EUR_TR_RelatedPOSMSubType__r.Name
                    FROM EUR_TR_POSM__c
                    WHERE EUR_TR_RelatedAccount__c = :filterModel.relatedAccount.Id AND EUR_TR_RelatedPOSMSubType__c != NULL AND RecordType.DeveloperName = 'EUR_TR_POSM'
            ]) {
                if (!POSMSubTypes.contains(POSMRecord.EUR_TR_RelatedPOSMSubType__r.Name)) {
                    POSMSubTypes.add(POSMRecord.EUR_TR_RelatedPOSMSubType__r.Name);
                } else {
                    continue;
                }
            }
        }
        List<EUR_TR_POSMDefinitionController.PicklistItem> items = new List<EUR_TR_POSMDefinitionController.PicklistItem>();
        EUR_TR_POSMDefinitionController.PicklistItem item = null;
        for (String POSMSubType : POSMSubTypes) {
            item = new EUR_TR_POSMDefinitionController.PicklistItem(POSMSubType, POSMSubType);
            items.add(item);
        }

        return items;

    }

    @TestVisible
    private static List<User> getActorsByRelatedAccount(EUR_TR_Account__c account) {

        List<SObject> approvalResultToSubmitter = [
                SELECT EUR_TR_Submitter__c
                FROM EUR_TR_Approval__c
                WHERE EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__c = :account.Id
                GROUP BY EUR_TR_Submitter__c
        ];

        List<SObject> approvalResultToApprover = [
                SELECT EUR_TR_Approver__c
                FROM EUR_TR_Approval__c
                WHERE EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__c = :account.Id
                GROUP BY EUR_TR_Approver__c
        ];

        return getUsersFromAggregatedApprovalResult(approvalResultToSubmitter, approvalResultToApprover);
    }

    private static List<User> getAllMyPOSMApprovalActors() {

        List<SObject> approvalResultToSubmitter = [
                SELECT EUR_TR_Submitter__c
                FROM EUR_TR_Approval__c
                WHERE EUR_TR_Approver__c = :UserInfo.getUserId()
                GROUP BY EUR_TR_Submitter__c
        ];
        List<SObject> approvalResultToApprover = [
                SELECT EUR_TR_Approver__c
                FROM EUR_TR_Approval__c
                WHERE EUR_TR_Submitter__c = :UserInfo.getUserId() AND EUR_TR_ApprovalProcessType__c = 'Revize Talebi'
                GROUP BY EUR_TR_Approver__c
        ];
        return getUsersFromAggregatedApprovalResult(approvalResultToSubmitter, approvalResultToApprover);

    }

    private static List<User> getUsersFromAggregatedApprovalResult(List<SObject> resultToSubmitter, List<SObject> resultToApprover) {

        Set<Id> actorIds = new Set<Id>();

        for (SObject approval : resultToSubmitter) {
            if (approval.get('EUR_TR_Submitter__c') != null) {
                actorIds.add((Id) approval.get('EUR_TR_Submitter__c'));
            }
        }

        for (SObject approval : resultToApprover) {
            if (approval.get('EUR_TR_Approver__c') != null) {
                actorIds.add((Id) approval.get('EUR_TR_Approver__c'));
            }
        }

        List<User> users = new List<User>();
        if (!actorIds.isEmpty()) {
            users = [SELECT Id,Name FROM User WHERE Id = :actorIds];
        }
        return users;
    }

    public static List<ButtonAction> getActionsByPOSMRecord(EUR_TR_POSM__c posm) {

        List<ButtonAction> actions = new List<ButtonAction>();
        ButtonAction action = new ButtonAction();
        if (posm.EUR_TR_ApprovalStatus__c != null) {
            if (posm.EUR_TR_ApprovalStatus__c == APPROVED) {
                action = new ButtonAction(CANCEL_ACTION_LABEL, CANCELED);
                actions.add(action);
            }
        }

        return actions;
    }

    private static void setApproverActions(EUR_TR_Approval__c approval, List<ButtonAction> approvalActions) {

        if (approval.EUR_TR_ApprovalProcessType__c.equalsIgnoreCase('Onay Talebi')) {

            if (approval.EUR_TR_ApprovalStatus__c.equalsIgnoreCase(PENDING)) {
                approvalActions.add(new ButtonAction(APPROVE_ACTION_LABEL, APPROVED));
                approvalActions.add(new ButtonAction(REJECT_ACTION_LABEL, REJECTED));
                approvalActions.add(new ButtonAction(REVISE_ACTION_LABEL, REVISE));
            } else if (approval.EUR_TR_ApprovalStatus__c.equalsIgnoreCase(APPROVED)) {
                approvalActions.add(new ButtonAction(CANCEL_ACTION_LABEL, CANCELED));
            }

        } else if (approval.EUR_TR_ApprovalProcessType__c.equalsIgnoreCase('İptal Talebi')) {

            if (approval.EUR_TR_ApprovalStatus__c.equalsIgnoreCase(PENDING)) {
                approvalActions.add(new ButtonAction(APPROVE_ACTION_LABEL, APPROVED));
                approvalActions.add(new ButtonAction(REJECT_ACTION_LABEL, REJECTED));
            }

        }

    }

    private static void setSubmitterActions(EUR_TR_Approval__c approval, List<ButtonAction> approvalActions) {

        if (approval.EUR_TR_ApprovalProcessType__c.equalsIgnoreCase('Onay Talebi')) {

            if (approval.EUR_TR_ApprovalStatus__c.equalsIgnoreCase(APPROVED)) {
                approvalActions.add(new ButtonAction(CANCEL_ACTION_LABEL, CANCELED));
            }

        } else if (approval.EUR_TR_ApprovalProcessType__c.equalsIgnoreCase('Revize Talebi')) {

            if (approval.EUR_TR_ApprovalStatus__c.equalsIgnoreCase(PENDING)) {
                approvalActions.add(new ButtonAction(APPROVE_ACTION_LABEL, APPROVED));
                approvalActions.add(new ButtonAction(REJECT_ACTION_LABEL, REJECTED));
            }

        }

    }

    public static void sendEmailToVendor(String emailAddress, String body) {

        if (String.isBlank(emailAddress) && String.isBlank(body)) {
            throw new EUR_TR_POSMApprovalControllerException('Tedarikçi email adres bilgisi ve mesajı boş bırakılamaz');
        }

        String subject = 'POSM Tedarik Süreci hk.';

        String htmlTemplate = '<html>\n' +
                '<head>' +
                '</head>\n' +
                '<body style="color:black;"><div>{0}</div></body> ' +
                '</html>' ;

        body = body.replace('\n', '<br />');
        htmlTemplate = String.format(htmlTemplate, new List<String>{
                body
        });

        List<Messaging.SendEmailResult> sendEmailResults = sendEmail(subject, new Set<String>{
                emailAddress
        }, body);
        if (!sendEmailResults.get(0).isSuccess()) {
            throw new EUR_TR_POSMApprovalControllerException('Tedarikçi firmaya mail gönderilirken hata meydana geldi.' + sendEmailResults.get(0).getErrors().get(0).getMessage());
        }
    }

    private static Boolean sendApprovalEmail(EUR_TR_Approval__c approval) {

        approval = [
                SELECT
                        Id,
                        CreatedDate,
                        EUR_TR_ApprovalProcessType__c,
                        EUR_TR_ApprovalStatus__c,
                        EUR_TR_Approver__r.Name,
                        EUR_TR_Submitter__r.Name,
                        EUR_TR_Approver__r.Email,
                        EUR_TR_Submitter__r.Email,
                        EUR_TR_RelatedPOSM__r.Name,
                        EUR_TR_RelatedPOSM__r.EUR_TR_POSMType__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_Brand__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_Budget__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_PlacementDate__c,
                        EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__r.Name
                FROM EUR_TR_Approval__c
                WHERE Id = :approval.Id
        ];

        if (String.isBlank(approval.EUR_TR_Approver__r.Email)) {
            throw new EUR_TR_POSMApprovalControllerException('Onaycı email adresi bulunamadı , lütfen yöneticiniz ile iletişime geçiniz!');
        }

        String htmlTemplate = '<html>\n' +
                '<head>' +
                '</head>\n' +
                '<body style="color:black;">{0}</body> ' +
                '</html>' ;

        String rows = '';
        rows = String.format('<p>{0},</p> <p>POSM Talebi için onayınız isteniyor.</p>', new List<String>{
                approval.EUR_TR_Approver__r.Name
        });
        String row = '<b>{0} :</b> {1}<br/>';
        rows += String.format(row, new List<String>{
                'POSM Türü', approval.EUR_TR_RelatedPOSM__r.EUR_TR_POSMType__c
        });
        rows += String.format(row, new List<String>{
                'Müşteri Adı', approval.EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__r.Name
        });
        rows += String.format(row, new List<String>{
                'Marka Adı', approval.EUR_TR_RelatedPOSM__r.EUR_TR_Brand__c
        });
        rows += String.format(row, new List<String>{
                'Talep Tarihi', approval.CreatedDate.format()
        });
        rows += String.format(row, new List<String>{
                'Talebi İleten Kişi', approval.EUR_TR_Submitter__r.Name
        });
        rows += String.format(row, new List<String>{
                'Bütçe', String.valueOf(approval.EUR_TR_RelatedPOSM__r.EUR_TR_Budget__c)
        });
        rows += String.format(row, new List<String>{
                'Konumlandırma Tarihi', approval.EUR_TR_RelatedPOSM__r.EUR_TR_PlacementDate__c.format('MM/dd/yyyy')
        });
        rows = String.format('<p{0}</p>', new List<String>{
                rows
        });

        rows += '<p>Bu kaydı onaylamak yada reddetmek için lütfen talep takip ekranınızı açınız.</p>';
        rows += '<p>Teşekkürler</p>';
        rows += '<p>Salesforce</p>';

        htmlTemplate = String.format(htmlTemplate, new List<String>{
                rows
        });

        Set<String> emailAddresses = new Set<String>();
        emailAddresses.add(approval.EUR_TR_Approver__r.Email);
        emailAddresses.add('osman.tuna@vesium.com');
        String subject = 'POSM Talebi Hk.';

        List<Messaging.SendEmailResult> sendEmailResults = sendEmail(subject, emailAddresses, htmlTemplate);
        return sendEmailResults.get(0).isSuccess();

    }

    public static List<Messaging.SendEmailResult> sendEmail(String subject, Set<String> emailAddresses, String emailBody) {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setHtmlBody(emailBody);
        email.setToAddresses(new List<String>(emailAddresses));
        email.setSenderDisplayName('Pernod Ricard Salesforce Destek');
        email.setSubject(subject);
        email.setUseSignature(false);
        email.setBccSender(false);
        email.setSaveAsActivity(false);
        List<Messaging.SendEmailResult> sendEmailResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                email
        });
        return sendEmailResults;

    }

    public static String successMessage { get; set; }
    public static String approverNotificationMessage { get; set; }
    public static String submitterNotificationMessage { get; set; }

    public class POSMApprovalRequestModel {
        public EUR_TR_POSM__c EURTRPOSMRecord { get; set; }
        public String actionName { get; set; }
        public String vendorEmailAddress { get; set; }
        public String emailBody { get; set; }
        public EUR_TR_Approval__c EURTRPOSMApprovalRecord { get; set; }
        public String approverComment { get; set; }
        public Boolean isVendorEmailFieldsControlRequired { get; set; }
    }

    public class POSMApprovalFilterModel extends EUR_TR_POSMController.POSMFilterModel {
        public POSMApprovalOrderBy orderBy { get; set; }
        public Id approvalId { get; set; }
    }

    public class POSMApprovalResult {
        public Integer totalRecordSize { get; set; }
        public List<EUR_TR_POSMController.POSMWrapper> records { get; set; }
    }

    public class ButtonAction {
        public ButtonAction() {
        }
        public ButtonAction(String label, String value) {
            this.label = label;
            this.value = value;
        }
        public String label { get; set; }
        public String value { get; set; }
    }

    public enum POSMApprovalOrderBy {
        createdDate, account, approvalType, approvalStatus
    }

    public static final String APPROVE_ACTION_LABEL = 'Onayla';
    public static final String CANCEL_ACTION_LABEL = 'İptal Et';
    public static final String REJECT_ACTION_LABEL = 'Reddet';
    public static final String REVISE_ACTION_LABEL = 'Geri Gönder';
    public static final String REVISE = 'Revize';
    public static final String APPROVED = 'Onaylandı';
    public static final String PENDING = 'Bekliyor';
    public static final String REJECTED = 'Reddedildi';
    public static final String COMPLETED = 'Tamamlandı';
    public static final String CANCELED = 'İptal Edildi';

    public class EURTRPOSMApprovalHistoryWrapper {
        public String customerName { get; set; }
        public String POSMType { get; set; }
        List<EURTRPOSMApprovalHistory> approvalHistories { get; set; }
    }

    public class EURTRPOSMApprovalHistory {
        public User actor { get; set; }
        public String approvalStatus { get; set; }
        public String approvalStatusLabel { get; set; }
        public String approverComments { get; set; }
        public Datetime actionTime { get; set; }
        public String approvalType { get; set; }
        public List<FieldChangeModel> changes { get; set; }

    }

    public class FieldChangeModel {

        public FieldChangeModel() {
        }

        public FieldChangeModel(String fieldLabel, String oldValue, String newValue) {
            this.fieldLabel = fieldLabel;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }

        public String oldValue { get; set; }
        public String newValue { get; set; }
        public String fieldLabel { get; set; }
        public String fieldName { get; set; }

    }

}