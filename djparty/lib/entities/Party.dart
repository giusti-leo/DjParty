import 'package:cloud_firestore/cloud_firestore.dart';

class PartyStatus {
  bool? isStarted;
  bool? isEnded;
  bool? isBackgrounded;

  PartyStatus(this.isStarted, this.isEnded, this.isBackgrounded);

  factory PartyStatus.getPartyFromFirestore(dynamic party) {
    return PartyStatus(
        party["isStarted"], party["isEnded"], party["isBackgrounded"]);
  }
}

class VotingStatus {
  int? timer;
  int? votingTime;
  Timestamp? nextVotingPhase;
  bool? voting;
  bool? countdown;

  VotingStatus(this.timer, this.votingTime, this.nextVotingPhase, this.voting,
      this.countdown);

  factory VotingStatus.getPartyFromFirestore(dynamic party) {
    return VotingStatus(party["timer"], party["votingTime"],
        party["nextVotingPhase"], party["votingStatus"], party["countdown"]);
  }
}

class MusicStatus {
  bool? selected;
  bool? firstVoting;
  int? times;
  bool? songs;
  bool? running;
  bool? pause;
  bool? resume;
  bool? backSkip;

  MusicStatus(this.selected, this.firstVoting, this.times, this.songs,
      this.running, this.pause, this.resume, this.backSkip);

  factory MusicStatus.getPartyFromFirestore(dynamic party) {
    return MusicStatus(
        party["selected"],
        party["firstVoting"],
        party["songsReproduced"],
        party["songs"],
        party['running'],
        party['pause'],
        party['resume'],
        party["backSkip"]);
  }
}

class Party {
  String admin;
  String code;
  String name;
  String reason;

  Party(this.code, this.name, this.admin, this.reason);

  factory Party.getPartyFromFirestore(dynamic party) {
    return Party(
        party["code"], party["partyName"], party["admin"], party["reason"]);
  }
}
