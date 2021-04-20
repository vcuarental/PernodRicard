<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_Approved_Price_Form_Notification</fullName>
        <description>ASI Approved Price Form Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_Base_Price_Setup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Pricing_Team_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Approved_Price_Form_Notification</template>
    </alerts>
    <alerts>
        <fullName>ASI_Approved_Price_Form_Notification_Advanced</fullName>
        <description>ASI Approved Price Form Notification (Advanced Price Setup)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_Advanced_Price_Setup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Base_Price_Setup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Pricing_Team_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/ASI_Approved_Price_Form_Notification_Advanced</template>
    </alerts>
    <alerts>
        <fullName>ASI_Pending_Price_Form_Notification</fullName>
        <description>ASI Pending Price Form Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Pending_Price_Form_Notification</template>
    </alerts>
    <alerts>
        <fullName>ASI_Pending_Price_Form_Notification_Advanced</fullName>
        <description>ASI Pending Price Form Notification (Advanced Price Setup)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_Advanced_Price_Setup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Base_Price_Setup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Pricing_Team_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/ASI_Pending_Price_Form_Notification_Advanced</template>
    </alerts>
    <alerts>
        <fullName>ASI_Pricing_Approval_Reminder_for_Forth_Approver_Alert</fullName>
        <description>ASI Pricing Approval Reminder for Forth Approver Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_Pricing_Forth_Level_Approval__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Approval_Request_Reminder</template>
    </alerts>
    <alerts>
        <fullName>ASI_Rejected_Price_Form_Notification</fullName>
        <description>ASI Rejected Price Form Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_Base_Price_Setup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Pricing_Team_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Rejected_Price_Form_Notification</template>
    </alerts>
    <alerts>
        <fullName>ASI_Rejected_Price_Form_Notification_Advanced</fullName>
        <description>ASI Rejected Price Form Notification (Advanced Price Setup)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_Advanced_Price_Setup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Base_Price_Setup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Pricing_Team_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/ASI_Rejected_Price_Form_Notification_Advanced</template>
    </alerts>
    <alerts>
        <fullName>ASI_Voided_Price_Form_Notification</fullName>
        <description>ASI Voided Price Form Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_Advanced_Price_Setup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Base_Price_Setup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Pricing_Team_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/ASI_Voided_Price_Form_Notification_Advanced</template>
    </alerts>
    <alerts>
        <fullName>Approval_Request_Reminder_for_First_Approver</fullName>
        <description>Approval Request Reminder for First Approver</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_Pricing_First_Level_Approval__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Approval_Request_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Approval_Request_Reminder_for_Second_Approver</fullName>
        <description>Approval Request Reminder for Second Approver</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_Pricing_Second_Level_Approval__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Approval_Request_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Approval_Request_Reminder_for_Third_Approver</fullName>
        <description>Approval Request Reminder for Third Approver</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_Pricing_Third_Level_Approval__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Approval_Request_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Approved_Price_Form_Notification</fullName>
        <description>Approved Price Form Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Approved_Price_Form_Notification</template>
    </alerts>
    <alerts>
        <fullName>Overdue_Pricing_Approval_Notification</fullName>
        <description>Overdue Pricing Approval Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Overdue_Pricing_Approval_Notification</template>
    </alerts>
    <alerts>
        <fullName>Pending_Price_Form_Notification</fullName>
        <description>Pending Price Form Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Pending_Price_Form_Notification</template>
    </alerts>
    <alerts>
        <fullName>Recalled_Price_Form_Notification_Before_First_Approval</fullName>
        <description>Recalled Price Form Notification Before First Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>james.maxwell@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Recalled_Price_Form_Notification</template>
    </alerts>
    <alerts>
        <fullName>Recalled_Price_Form_Notification_Before_Second_Approval</fullName>
        <description>Recalled Price Form Notification Before Second Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>pierre-edouard.miot@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Recalled_Price_Form_Notification</template>
    </alerts>
    <alerts>
        <fullName>Recalled_Price_Form_Notification_Before_Third_Approval</fullName>
        <description>Recalled Price Form Notification Before Third Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>mohit.lal@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Recalled_Price_Form_Notification</template>
    </alerts>
    <alerts>
        <fullName>Rejected_Price_Form_Notification</fullName>
        <description>Rejected Price Form Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_Finance_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_KAM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_Logistics_Team__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_SSC_Logistic__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Pricing_Approval/Rejected_Price_Form_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_Clear_Remarks</fullName>
        <field>ASI_Remarks__c</field>
        <name>ASI Clear Remarks</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_Mark_Recall_Flag</fullName>
        <field>ASI_Recall__c</field>
        <literalValue>1</literalValue>
        <name>ASI Mark Recall Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_Mark_Recall_Flag_False</fullName>
        <field>ASI_Recall__c</field>
        <literalValue>0</literalValue>
        <name>ASI Mark Recall Flag False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_Pricing_Submitted_Status</fullName>
        <field>ASI_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>ASI_Pricing_Submitted_Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_Set_Status_to_Complete</fullName>
        <field>ASI_Status__c</field>
        <literalValue>Complete</literalValue>
        <name>ASI Set Status to Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Approved_Level</fullName>
        <field>ASI_Approved_Level__c</field>
        <formula>0</formula>
        <name>Reset Approved Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Reminder_Date</fullName>
        <field>ASI_Last_Reminder_Date__c</field>
        <name>Reset Reminder Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Reminder_Date</fullName>
        <field>ASI_Last_Reminder_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Reminder Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_To_Final_Approved</fullName>
        <field>ASI_Status__c</field>
        <literalValue>Final Approved</literalValue>
        <name>Set Status To Final Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_To_Pending_1st_Approval</fullName>
        <field>ASI_Status__c</field>
        <literalValue>Pending First Approval</literalValue>
        <name>Set Status To Pending 1st Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_To_Pending_2nd_Approval</fullName>
        <field>ASI_Status__c</field>
        <literalValue>Pending Second Approval</literalValue>
        <name>Set Status To Pending 2nd Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_To_Recalled</fullName>
        <field>ASI_Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Set Status To Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_To_Rejected</fullName>
        <field>ASI_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Set Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Pending_3rd_Approval</fullName>
        <field>ASI_Status__c</field>
        <literalValue>Pending Third Approval</literalValue>
        <name>Set Status to Pending 3rd Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Submission_Date</fullName>
        <field>ASI_Submission_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Submission Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approved_Level</fullName>
        <field>ASI_Approved_Level__c</field>
        <formula>ASI_Approved_Level__c + 1</formula>
        <name>Update Approved Level</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI Voided Price Form</fullName>
        <actions>
            <name>ASI_Voided_Price_Form_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify all approvers when record is voided</description>
        <formula>AND(ISCHANGED(ASI_Status__c), ISPICKVAL(ASI_Status__c,&apos;Void&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Recalled Price Form Notification Before First Approval</fullName>
        <actions>
            <name>Recalled_Price_Form_Notification_Before_First_Approval</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Approved_Level</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_Pricing_Approval__c.ASI_Status__c</field>
            <operation>equals</operation>
            <value>Recalled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_Pricing_Approval__c.ASI_Approved_Level__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recalled Price Form Notification Before Second Approval</fullName>
        <actions>
            <name>Recalled_Price_Form_Notification_Before_Second_Approval</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Approved_Level</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_Pricing_Approval__c.ASI_Status__c</field>
            <operation>equals</operation>
            <value>Recalled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_Pricing_Approval__c.ASI_Approved_Level__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recalled Price Form Notification Before Third Approval</fullName>
        <actions>
            <name>Recalled_Price_Form_Notification_Before_Third_Approval</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Approved_Level</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_Pricing_Approval__c.ASI_Status__c</field>
            <operation>equals</operation>
            <value>Recalled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_Pricing_Approval__c.ASI_Approved_Level__c</field>
            <operation>equals</operation>
            <value>2</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>