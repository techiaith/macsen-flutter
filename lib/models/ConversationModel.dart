

class ConversationModel {
  bool isActive = false;
  bool isListening = false;
  bool isSpeaking = false;
  bool isWaiting = false;

  ConversationModel clone(){
    ConversationModel copy = new ConversationModel();
    copy.isListening=isListening;
    copy.isWaiting=isWaiting;
    copy.isSpeaking=isSpeaking;
    copy.isActive=isActive;
    return copy;
  }

}