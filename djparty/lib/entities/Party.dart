import 'package:cloud_firestore/cloud_firestore.dart';

class Party {
  final List<String> partecipantList;
  final String partyName;
  final String admin;
  final String code;
  final Timestamp creationTime;
  final Timestamp nextVotingPhase;
  final Timestamp startParty;
  final int timer;
  final int votingTime;
  final bool votingStatus;
  final bool isEnded;
  final bool isStarted;
  final int songsReproduced;
  final String status;

  Party(
      this.partecipantList,
      this.partyName,
      this.admin,
      this.code,
      this.timer,
      this.songsReproduced,
      this.votingTime,
      this.creationTime,
      this.nextVotingPhase,
      this.startParty,
      this.votingStatus,
      this.isEnded,
      this.isStarted,
      this.status);

  factory Party.getPartyFromFirestore(dynamic party) {
    List<dynamic> partecipants = party['partecipant_list'];
    List<String> partecipantList = [];

    for (var element in partecipants) {
      partecipantList.add(element.toString());
    }
    return Party(
        partecipantList,
        party["partyName"],
        party["admin"],
        party["code"],
        party["timer"],
        party["songsReproduced"],
        party["votingTime"],
        party["creationTime"],
        party["nextVotingPhase"],
        party["startParty"],
        party["votingStatus"],
        party["isEnded"],
        party["isStarted"],
        party["status"]);
  }
}
