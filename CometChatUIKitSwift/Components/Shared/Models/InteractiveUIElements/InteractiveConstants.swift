//
//  InteractiveConstants.swift
//  
//
//  Created by Admin on 25/09/23.
//

import Foundation

public struct InteractiveConstants {
    public static var INTERACTIVE_MESSAGE_FORM_FIELD = "formFields";
    public static var INTERACTIVE_MESSAGE_SUBMIT_ELEMENT = "submitElement";
    public static var TITLE = "title";
    public static var AVATAR_URL = "avatarUrl"
    public static var GOAL_COMPELTION_TEXT = "goalCompletionText"
    
    public static var ELEMENT_TYPE = "elementType";
    public static var ELEMENT_ID = "elementId";
    public static var value = "value"
    
    public static var CARD_ACTIONS = "cardActions"
    public static var IMAGE_URL = "imageUrl";
    public static var TEXT = "text";
    
    public static var BUFFER_TIME = "bufferTime"
    public static var MEETING_DURATION = "meetingDuration"
    public static var AVAILABILITY = "availability"
    public static var DATE_RANGE_START = "dateRangeStart"
    public static var DATE_RANGE_END = "dateRangeEnd"
    public static var ICS_FILE_URL = "icsFileUrl"
    public static var SCHEDULE_ELEMENT = "scheduleElement"
    public static var TIME_ZONE_CODE = "timezoneCode"
    public static var DURATION = "duration"
    public static var MEET_STARTED_AT = "meetStartAt"
    
    public struct OptionElementConstants {
        public static var LABEL = "label";
        public static var VALUE = "value";
    }
    
    public struct ElementsType {
        
        public static var TEXT_INPUT = "textInput";
        public static var RADIO_BUTTON = "radio";
        public static var LABEL = "label";
        public static var DROP_DOWN = "dropdown";
        public static var CHECK_BOX = "checkbox";
        public static var BUTTON = "button";
    }
    
    public struct TextInputUIConstants {
        
        public static var ENABLED = "enabled";
        public static var OPTIONAL = "optional";
        public static var LABEL = "label";
        public static var MAX_LINES = "maxLines";
        public static var PLACEHOLDER = "placeholder";
        public static var PLACEHOLDER_TEXT = "text";
        public static var DEFAULT_VALUE = "defaultValue";
    }
    
    public struct RadioButtonUIConstants {
        public static var ENABLED = "enabled";
        public static var OPTIONAL = "optional";
        public static var LABEL = "label";
        public static var OPTIONS = "options";
        public static var OPTION_ID = "id";
        public static var OPTION_VALUE = "value";
        public static var OPTION_SELECTED = "selected";
        public static var DEFAULT_VALUE = "defaultValue";
    }
    
    public struct LabelUIConstants {
        public static var TEXT = "text";
    }
    
    public struct DropDownUIConstants {
        public static var ENABLED = "enabled";
        public static var OPTIONAL = "optional";
        public static var LABEL = "label";
        public static var DEFAULT_OPTION = "defaultOption";
        public static var OPTIONS = "options";
        public static var OPTION_LABEL = "label";
        public static var OPTION_VALUE = "value";
        public static var DEFAULT_VALUE = "defaultValue";
    }
    
    public struct CheckBoxUIConstants {
        public static var ENABLED = "enabled";
        public static var OPTIONAL = "optional";
        public static var LABEL = "label";
        public static var OPTIONS = "options";
        public static var OPTION_LABEL = "label";
        public static var OPTION_VALUE = "value";
        public static var OPTION_SELECTED = "selected";
        public static var DEFAULT_VALUE = "defaultValue";
        
    }
    
    public struct SingleSelectUIConstants {
        public static var ENABLED = "enabled";
        public static var OPTIONAL = "optional";
        public static var LABEL = "label";
        public static var DEFAULT_VALUE = "DEFAULT_VALUE";
        public static var OPTIONS = "options";
        public static var OPTION_LABEL = "label";
        public static var OPTION_VALUE = "value";
    }
    
    public struct ButtonUIConstants {
        public static var ENABLE = "enable";
        public static var BUTTONTEXT = "buttonText";
        public static var ACTION = "action";
        public static var ACTION_TYPE = "actionType";
        public static var ACTION_TYPE_ = "type";
        public static var ACTION_URL = "url";
        public static var ACTION_PAYLOAD = "payload";
        public static var ACTION_HEADERS = "headers";
        public static var ACTION_DATA_KEY = "dataKey";
        public static var METHOD = "method";
        public static var ACTION_API = "apiAction";
        public static var DISABLE_AFTER_INTERACTED = "disableAfterInteracted";
        public static var APP_ID = "appID";
        public static var REGION = "region";
        public static var TRIGGER = "trigger";
        public static var PAYLOAD = "payload";
        public static var CONVERSATION_ID = "conversationId"
        public static var SENDER = "sender"
        public static var RECEIVER = "receiver"
        public static var RECEIVER_TYPE = "receiverType"
        public static var MESSAGE_CATEGORY = "messageCategory"
        public static var MESSAGE_ID = "messageId"
        public static var INTERACTION_TIMEZONE_CODE = "interactionTimezoneCode"
        public static var INTERACTED_BY = "interactedBy"
        public static var INTERACTED_ELEMENT_ID = "interactedElementId"
        public static var MESSAGE_TYPE = "messageType"
        public static var UI_MESSAGE_INTERACTED = "ui_message_interacted"
        public static var SCHEDULER_DATA = "schedulerData"
    }
    
    public struct DateTimeConstants {
        public static var VALUE = "value"
        public static var TIME_ZONE = "timezoneCode"
        public static var OPTIONAL = "optional"
        public static var LABEL = "label"
        public static var DEFAULT_VALUE = "defaultValue"
        public static var DATE_TIME_FORMATE = "dateTimeFormat"
        public static var MODE = "mode"
        public static var FROM = "from"
        public static var TO = "to"
        public static var ACTION_API = "apiAction";
        public static var DISABLE_AFTER_INTERACTED = "disableAfterInteracted";
        public static var APP_ID = "appID";
        public static var REGION = "region";
        public static var TRIGGER = "trigger";
        public static var PAYLOAD = "payload";
        public static var CONVERSATION_ID = "conversationId"
        public static var SENDER = "sender"
        public static var RECEIVER = "receiver"
        public static var RECEIVER_TYPE = "receiverType"
        public static var MESSAGE_CATEGORY = "messageCategory"
        public static var MESSAGE_ID = "messageId"
        public static var INTERACTION_TIMEZONE_CODE = "interactionTimezoneCode"
        public static var INTERACTED_BY = "interactedBy"
        public static var INTERACTED_ELEMENT_ID = "interactedElementId"
        public static var MESSAGE_TYPE = "messageType"
        public static var UI_MESSAGE_INTERACTED = "ui_message_interacted"
        public static var SCHEDULER_DATA = "schedulerData"
    }
}
