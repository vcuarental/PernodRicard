<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_eForm_KR_CorpCard_CCL_Approved</fullName>
        <ccEmails>bluesun@shinhan.com</ccEmails>
        <description>ASI_eForm_KR_CorpCard_CCL_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_CorpCard_CCL_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_eForm_KR_CorpCard_CCL_Rejected</fullName>
        <description>ASI_eForm_KR_CorpCard_CCL_Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_CorpCard_CCL_Rejected</template>
    </alerts>
    <alerts>
        <fullName>ASI_eForm_KR_CorpCard_Cancellation_Approved</fullName>
        <ccEmails>bluesun@shinhan.com</ccEmails>
        <description>ASI_eForm_KR_CorpCard_Cancellation_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_CorpCard_Cancellation_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_eForm_KR_CorpCard_Cancellation_Rejected</fullName>
        <description>ASI_eForm_KR_CorpCard_Cancellation_Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_CorpCard_Cancellation_Rejected</template>
    </alerts>
    <alerts>
        <fullName>ASI_eForm_KR_CorpCard_New_Approved</fullName>
        <ccEmails>bluesun@shinhan.com</ccEmails>
        <description>ASI_eForm_KR_CorpCard_New_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_CorpCard_New_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_eForm_KR_CorpCard_New_Rejected</fullName>
        <description>ASI_eForm_KR_CorpCard_New_Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_CorpCard_New_Rejected</template>
    </alerts>
    <alerts>
        <fullName>ASI_eForm_KR_CorpCard_Reissue_Approved</fullName>
        <ccEmails>bluesun@shinhan.com</ccEmails>
        <description>ASI_eForm_KR_CorpCard_Reissue_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_CorpCard_Reissue_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_eForm_KR_CorpCard_Reissue_Rejected</fullName>
        <description>ASI_eForm_KR_CorpCard_Reissue_Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_CorpCard_Reissue_Rejected</template>
    </alerts>
    <alerts>
        <fullName>ASI_eForm_KR_CorpCard_Suspension_Approved</fullName>
        <ccEmails>bluesun@shinhan.com</ccEmails>
        <description>ASI_eForm_KR_CorpCard_Suspension_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_CorpCard_Suspension_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_eForm_KR_CorpCard_Suspension_Rejected</fullName>
        <description>ASI_eForm_KR_CorpCard_Suspension_Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_CorpCard_Suspension_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_eForm_AllowSubmit_False</fullName>
        <field>ASI_eForm_Sys_Allow_Submit_Approval__c</field>
        <literalValue>0</literalValue>
        <name>ASI_eForm_AllowSubmit_False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_KR_CorpCard_CCL_RO</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_eForm_KR_CC_Request_Change_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_eForm_KR_CorpCard_CCL_RO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_KR_CorpCard_CancelRTApproval</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_eForm_KR_CC_Request_Cancellation_Approval</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_eForm_KR_CorpCard_CancelRTApproval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_KR_CorpCard_Cancellation_RO</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_eForm_KR_CC_Request_Cancellation_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_eForm_KR_CorpCard_Cancellation_RO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_KR_CorpCard_Cancellation_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_eForm_KR_CC_Request_Cancellation</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_eForm_KR_CorpCard_Cancellation_RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_KR_CorpCard_New_RO</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_eForm_KR_CC_Request_New_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_eForm_KR_CorpCard_New_RO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_KR_CorpCard_Reissue_RO</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_eForm_KR_CC_Request_Reissue_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_eForm_KR_CorpCard_Reissue_RO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_KR_CorpCard_SuspenseRTApproval</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_eForm_KR_CC_Request_Suspension_Approval</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_eForm_KR_CorpCard_SuspenseRTApproval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_KR_CorpCard_Suspension_RO</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_eForm_KR_CC_Request_Suspension_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_eForm_KR_CorpCard_Suspension_RO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_KR_CorpCard_Suspension_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_eForm_KR_CC_Request_Suspension</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_eForm_KR_CorpCard_Suspension_RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_Status_Approved</fullName>
        <field>ASI_eForm_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>ASI_eForm_Status_Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_Status_Draft</fullName>
        <field>ASI_eForm_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>ASI_eForm_Status_Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_Status_Rejected</fullName>
        <field>ASI_eForm_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>ASI_eForm_Status_Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_Status_Submitted</fullName>
        <field>ASI_eForm_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>ASI_eForm_Status_Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
