<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_CN_Auto_Send_PaymentInstruction</fullName>
        <description>Payment instruction auto send to WS /Outlet only if instruction date is input.</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_CRM_CN_Sales_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_T1_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_WS_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_Payment_Instruction_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_CN_Auto_Send_PaymentInstruction_User</fullName>
        <description>Send Email to User when Promotion Type not Contract ON/Off</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_Payment_Instruction_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_CN_SD_Email_T1</fullName>
        <description>SD Email To T1 WS, WS manager, Sales, regional accountant</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_CRM_CN_Regional_Accountant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_Sales_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_T1_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_WS_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_Payment_Instruction_Template2</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_CN_SD_Email_To_T1_Lessthan0</fullName>
        <description>SD Email To T1 WS, WS manager, Sales, regional accountant Less than 0</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_CRM_CN_Regional_Accountant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_Sales_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_T1_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_WS_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_Payment_Instruction_Template3</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_CN_SD_Email_To_T2</fullName>
        <description>SD Email To T2 WS, WS manager, Sales, regional accountant</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_CRM_CN_Regional_Accountant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_Sales_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_T2_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_WS_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_Payment_Instruction_Template4</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_CN_SD_Email_To_T2_Lessthan0</fullName>
        <description>SD Email To T2 WS, WS manager, Sales, regional accountant Less than 0</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_CRM_CN_Regional_Accountant_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_Sales_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_T2_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_CRM_CN_WS_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_Payment_Instruction_Template5</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Sales_Email</fullName>
        <field>ASI_CRM_CN_Sales_Email__c</field>
        <formula>ASI_CRM_CN_Payment_Request__r.Owner:User.Email</formula>
        <name>Sales Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_T1_Email</fullName>
        <description>Copy T1 Email</description>
        <field>ASI_CRM_CN_T1_Email__c</field>
        <formula>ASI_CRM_CN_Payee_Name_T1__r.ASI_CRM_CN_Email__c</formula>
        <name>T1 Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_T2_Email</fullName>
        <description>Copy T2 Email</description>
        <field>ASI_CRM_CN_T2_Email__c</field>
        <formula>ASI_CRM_CN_Payee_Name_T2_lookup__r.ASI_CRM_CN_Email__c</formula>
        <name>T2 Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Update_Instruction_Send</fullName>
        <field>ASI_CRM_CN_Instruction_Send__c</field>
        <literalValue>0</literalValue>
        <name>Update Instruction Send</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Update_Instruction_Send_Date</fullName>
        <field>ASI_CRM_CN_Instruction_Send_Date__c</field>
        <formula>Today()</formula>
        <name>Update Instruction Send Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Update_Instruction_Send_Time</fullName>
        <field>ASI_CRM_CN_Instruction_Sent_Time__c</field>
        <formula>NOW()</formula>
        <name>Update Instruction Send Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_WS_Manager1_Email</fullName>
        <field>ASI_CRM_CN_WS_Manager_Email__c</field>
        <formula>ASI_CRM_CN_Payment_Request__r.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_WS_Manager__r.Email</formula>
        <name>WS Manager Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_Regional_Accountant_Email</fullName>
        <field>ASI_CRM_CN_Regional_Accountant_Email__c</field>
        <formula>ASI_CRM_CN_Payment_Request__r.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Regional_Accountant__r.Email</formula>
        <name>Regional Accountant Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_CN_Copy T1 %26 T2 Email</fullName>
        <actions>
            <name>ASI_CRM_CN_T1_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_T2_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>ASI_CRM_CN_PH_Payee_Line_Item__c.ASI_CRM_CN_T2_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Copy T1 &amp; T2 Email from Payee</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_CN_Send Email to Outlet%2FWS 2</fullName>
        <actions>
            <name>ASI_CRM_CN_SD_Email_T1</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_SD_Email_To_T2</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_Sales_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_T1_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_T2_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_Update_Instruction_Send</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_Update_Instruction_Send_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_WS_Manager1_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_Regional_Accountant_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_CN_PH_Payee_Line_Item__c.ASI_CRM_CN_Instruction_Send__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_CN_PH_Payee_Line_Item__c.ASI_CRM_CN_Type__c</field>
            <operation>notEqual</operation>
            <value>Cash</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_CN_PH_Payee_Line_Item__c.ASI_CRM_CN_Amount__c</field>
            <operation>greaterOrEqual</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_CN_Send Email to Outlet%2FWS 3</fullName>
        <actions>
            <name>ASI_CRM_CN_SD_Email_To_T1_Lessthan0</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_SD_Email_To_T2_Lessthan0</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_Sales_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_T1_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_T2_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_Update_Instruction_Send</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_Update_Instruction_Send_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_CN_WS_Manager1_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_Regional_Accountant_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_CN_PH_Payee_Line_Item__c.ASI_CRM_CN_Instruction_Send__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_CN_PH_Payee_Line_Item__c.ASI_CRM_CN_Type__c</field>
            <operation>notEqual</operation>
            <value>Cash</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_CN_PH_Payee_Line_Item__c.ASI_CRM_CN_Amount__c</field>
            <operation>lessThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
