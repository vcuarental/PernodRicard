<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_VN_ActivateSup_Approval_Email_for_Marketing</fullName>
        <description>ASI CRM VN Activation Support Contract Approval Email for Marketing</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CRM_VN_Contract_Approver</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_ActivateSup_MktApprovalEmail</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_ActivateSup_Approved_EmailAlert</fullName>
        <description>ASI CRM VN Activation Support Contract Approved Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_ActivateSup_ApprovedEmailTemp</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_ActivateSup_Reject_EmailAlert</fullName>
        <description>ASI CRM VN Activation Support Contract Reject Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_ActivateSup_RejectEmail_Temp</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_CapAgreement_ApprovedEmail_Alert</fullName>
        <description>ASI CRM VN Capsule Agreement Approved Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_CapAgreement_Approved_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_CapAgreement_MktApprovalEmail_Alert</fullName>
        <description>ASI CRM VN Capsule Agreement Approval Email for Marketing</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CRM_VN_Contract_Approver</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_CapAgre_MktApprovalEmail</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_CapAgreement_RejectEmail_Alert</fullName>
        <description>ASI CRM VN Capsule Agreement Reject Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_CapAgreement_Reject_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_Close_Contract_Approved_Alert</fullName>
        <description>ASI CRM VN Close Contract Approved Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_CloseContract_Approved_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_Close_Contract_Rejected_Alert</fullName>
        <description>ASI CRM VN Close Contract Rejected Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_CloseContract_Reject_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_Contract_ApprovedEmail_Alert</fullName>
        <description>ASI CRM VN Contract Approved Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_Contract_ApprovedEmail_Temp</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_Contract_MktApprovalEmail_Alert</fullName>
        <description>ASI CRM VN Contract Approval Email for Marketing</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CRM_VN_Contract_Approver</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_Contract_MktApprovalEmail</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_Contract_RejectEmail_Alert</fullName>
        <description>ASI CRM VN Contract Reject Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_Contract_RejectEmail_Temp</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_Contract_TradeMkt_ApprovalEmail_Alert</fullName>
        <description>ASI CRM VN Contract Approval Email for Trade Marketing</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CRM_VN_Trade_Marketing_Team</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_Contract_TradeMktAplEmail_Tmp</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_Extend_Contract_Approved_Alert</fullName>
        <description>ASI CRM VN Extend Contract Approved Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_ExtendContract_Approved_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_Extend_Contract_Reject_Alert</fullName>
        <description>ASI CRM VN Extend Contract Reject Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_ExtendContract_Reject_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Clear_New_End_Date</fullName>
        <field>ASI_CRM_New_End_Date__c</field>
        <name>ASI CRM VN Clear New End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Contract_Approved</fullName>
        <field>ASI_CRM_Contract_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>ASI CRM VN Contract Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Contract_Close</fullName>
        <field>ASI_CRM_Contract_Status__c</field>
        <literalValue>Closed</literalValue>
        <name>ASI CRM VN Contract Close</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Contract_Draft</fullName>
        <field>ASI_CRM_Contract_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>ASI CRM VN Contract Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Contract_Pending_Verification</fullName>
        <field>ASI_CRM_Contract_Status__c</field>
        <literalValue>Pending Verification</literalValue>
        <name>ASI CRM VN Contract Pending Verification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Contract_Submitted</fullName>
        <field>ASI_CRM_Contract_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>ASI CRM VN Contract Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Contract_Terminated</fullName>
        <field>ASI_CRM_Contract_Status__c</field>
        <literalValue>Closed(Terminated)</literalValue>
        <name>ASI CRM VN Contract Terminated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Set_Allow_Extend_False</fullName>
        <field>ASI_CRM_Allow_Extend__c</field>
        <literalValue>0</literalValue>
        <name>ASI CRM VN Set Allow Extend False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Set_Close_Date</fullName>
        <field>ASI_CRM_Closed_Date__c</field>
        <formula>Today()</formula>
        <name>ASI CRM VN Set Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Set_New_End_Date</fullName>
        <field>ASI_CRM_End_Date__c</field>
        <formula>ASI_CRM_New_End_Date__c</formula>
        <name>ASI CRM VN Set New End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Set_Original_End_Date</fullName>
        <field>ASI_CRM_Original_End_Date__c</field>
        <formula>ASI_CRM_End_Date__c</formula>
        <name>ASI CRM VN Set Original End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Set_Termination_False</fullName>
        <field>ASI_CRM_Sys_Force_Termination__c</field>
        <literalValue>0</literalValue>
        <name>ASI CRM VN Set Termination False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_VN_ContractApproved</fullName>
        <actions>
            <name>ASI_CRM_VN_Contract_TradeMkt_ApprovalEmail_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_VN_Contract__c.ASI_CRM_Contract_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_VN_Contract__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI CRM VN Contract</value>
        </criteriaItems>
        <description>Send email to Trade Marketing team when contract is approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_VN_ContractClosed</fullName>
        <actions>
            <name>ASI_CRM_VN_Set_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_VN_Contract__c.ASI_CRM_Contract_Status__c</field>
            <operation>equals</operation>
            <value>Closed,Closed(Terminated)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
