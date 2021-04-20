<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_CN_IOM_Rejected_Email_Alert</fullName>
        <description>ASI_CRM_CN_IOM_Rejected_Email_Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_CRM_Approval_Submitter_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_IOM_Request_Rejected_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_CN_Image_Outlet_Request_Approved_Email_Alert</fullName>
        <description>CN Image Outlet Request Approved Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_IOM_Approved_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_CN_Image_Outlet_Request_Approved_Email_Alert2</fullName>
        <description>CN Image Outlet Request Approved Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_Notificaton_Merchindising__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_Sys_Approver_2__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_Sys_Approver_Channel__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_Sys_Approver_Region__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_Sys_Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_IOM_Approved_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_CN_Image_Outlet_Request_Approved_Notify_PMO</fullName>
        <ccEmails>prc.iomapprove@pernod-ricard.com</ccEmails>
        <description>CN Image Outlet Request Approved Notify PMO</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_IOM_Request_Approved_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_CN_Image_Outlet_Request_Rejected_Email_Alert</fullName>
        <description>CN Image Outlet Request Rejected Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_IOM_Rejected_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_IOM_Update_Initial_Submitter</fullName>
        <field>ASI_CRM_Approval_Submitter_Email__c</field>
        <formula>$User.Email</formula>
        <name>Update Initial Submitter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Set_Status_Approved_by_AD</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Preliminary Approved</literalValue>
        <name>Set Status Preliminary Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Set_Status_Approved_by_HQ</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Budget Approved</literalValue>
        <name>Set Status Budget Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Set_Status_Draft</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Set Status Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Set_Status_Rejected_by_HQ</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Set Status Rejected by HQ</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Set_Status_Submitted_HQ</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Submitted for Budget Approval</literalValue>
        <name>Set Status Submitted for Budget</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Set_Status_Submitted_to_AD</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Submitted to RTMK</literalValue>
        <name>Set Status Submitted to RTMK</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_CN_IOM_PreliminaryApproved_Email</fullName>
        <actions>
            <name>ASI_CRM_CN_Image_Outlet_Request_Approved_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL( PRIORVALUE( ASI_CRM_Status__c), &quot;Submitted to RTMK&quot; ) &amp;&amp; ISPICKVAL( ASI_CRM_Status__c, &quot;Preliminary Approved&quot; ) &amp;&amp; (RecordType.DeveloperName == &quot;ASI_CRM_CN_Image_Outlet_Request&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_CN_IOM_Rejected_Approved_Alert</fullName>
        <actions>
            <name>ASI_CRM_CN_Image_Outlet_Request_Approved_Email_Alert2</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(ASI_CRM_Status__c, &quot;Budget Approved&quot;) &amp;&amp; ISPICKVAL(PRIORVALUE( ASI_CRM_Status__c), &quot;Submitted for Budget Approval&quot;) &amp;&amp; ( CONTAINS(RecordType.DeveloperName, &quot;ASI_CRM_CN_Image_Outlet_Request&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_CN_IOM_Rejected_Email_Alert</fullName>
        <actions>
            <name>ASI_CRM_CN_Image_Outlet_Request_Rejected_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>OR(ISPICKVAL(ASI_CRM_Status__c, &quot;Preliminary Approved&quot;) &amp;&amp; ISPICKVAL(PRIORVALUE( ASI_CRM_Status__c), &quot;Submitted for Budget Approval&quot;),ISPICKVAL(ASI_CRM_Status__c, &quot;Draft&quot;) &amp;&amp; ISPICKVAL(PRIORVALUE( ASI_CRM_Status__c), &quot;Submitted to RTMK&quot;)) &amp;&amp; ( CONTAINS(RecordType.DeveloperName, &quot;ASI_CRM_CN_Image_Outlet_Request&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
