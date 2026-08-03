//
//  "cometChatEmojiKeyboardJSON.swift
//  "created by abdullah ansari on 08/06/22.
//

import Foundation


struct CometChatEmojiCategoryJSON {
    
    // Defensive (ENG-37757): Data(_:utf8) emits no reference to Foundation's
    // `data(using:allowLossyConversion:)` at all. At this target (15.1) the old call
    // resolved to the StringProtocol overload, which back-deploys fine; the crashing
    // concrete-String overload is only selected at a deployment target >= iOS 18.
    // Using Data(_:utf8) keeps that true even if the target is ever raised.
    private static var json = Data(
    """
    {
      "emojiCategory":
      [
      {
          "id": "people",
          "name": "Smileys",
          "symbol": "messages-emoji-keyboard-smileys.png",
          "emojis": [
              {
              "keywords": [
                "face",
                "smile",
                "happy",
                "joy",
                ":D",
                "grin"
              ],
              "emoji": "😀"
            },
            {
              "keywords": [
                "face",
                "grimace",
                "teeth"
              ],
              "emoji": "😬"
            },
            {
              "keywords": [
                "face",
                "happy",
                "smile",
                "joy",
                "kawaii"
              ],
              "emoji": "😁"
            },
            {
              "keywords": [
                "face",
                "cry",
                "tears",
                "weep",
                "happy",
                "happytears",
                "haha"
              ],
              "emoji": "😂"
            },
            {
              "keywords": [
                "face",
                "rolling",
                "floor",
                "laughing",
                "lol",
                "haha"
              ],
              "emoji": "🤣"
            },
            {
              "keywords": [
                "face",
                "celebration",
                "woohoo"
              ],
              "emoji": "🥳"
            },
            {
              "keywords": [
                "face",
                "happy",
                "joy",
                "haha",
                ":D",
                ":)",
                "smile",
                "funny"
              ],
              "emoji": "😃"
            },
            {
              "keywords": [
                "face",
                "happy",
                "joy",
                "funny",
                "haha",
                "laugh",
                "like",
                ":D",
                ":)"
              ],
              "emoji": "😄"
            },
            {
              "keywords": [
                "face",
                "hot",
                "happy",
                "laugh",
                "sweat",
                "smile",
                "relief"
              ],
              "emoji": "😅"
            },
            {
              "keywords": [
                "happy",
                "joy",
                "lol",
                "satisfied",
                "haha",
                "face",
                "glad",
                "XD",
                "laugh"
              ],
              "emoji": "😆"
            },
            {
              "keywords": [
                "face",
                "angel",
                "heaven",
                "halo"
              ],
              "emoji": "😇"
            },
            {
              "keywords": [
                "face",
                "happy",
                "mischievous",
                "secret",
                ";)",
                "smile",
                "eye"
              ],
              "emoji": "😉"
            },
            {
              "keywords": [
                "face",
                "smile",
                "happy",
                "flushed",
                "crush",
                "embarrassed",
                "shy",
                "joy"
              ],
              "emoji": "😊"
            },
            {
              "keywords": [
                "face",
                "smile"
              ],
              "emoji": "🙂"
            },
             {
              "keywords": [
                "face",
                "flipped",
                "silly",
                "smile"
              ],
              "emoji": "🙃"
            },
            {
              "keywords": [
                "face",
                "blush",
                "massage",
                "happiness"
              ],
              "emoji": "☺️"
            },
            {
              "keywords": [
                "happy",
                "joy",
                "tongue",
                "smile",
                "face",
                "silly",
                "yummy",
                "nom",
                "delicious",
                "savouring"
              ],
              "emoji": "😋"
            },
            {
              "keywords": [
                "face",
                "relaxed",
                "phew",
                "massage",
                "happiness"
              ],
              "emoji": "😌"
            },
            {
              "keywords": [
                "face",
                "love",
                "like",
                "affection",
                "valentines",
                "infatuation",
                "crush",
                "heart"
              ],
              "emoji": "😍"
            },
            {
              "keywords": [
                "face",
                "love",
                "like",
                "affection",
                "valentines",
                "infatuation",
                "crush",
                "hearts",
                "adore"
              ],
              "emoji": "🥰"
            },
            {
              "keywords": [
                "face",
                "love",
                "like",
                "affection",
                "valentines",
                "infatuation",
                "kiss"
              ],
              "emoji": "😘"
            },
            {
              "keywords": [
                "love",
                "like",
                "face",
                "3",
                "valentines",
                "infatuation",
                "kiss"
              ],
              "emoji": "😗"
            },
            {
              "keywords": [
                "face",
                "affection",
                "valentines",
                "infatuation",
                "kiss"
              ],
              "emoji": "😙"
            },
            {
              "keywords": [
                "face",
                "love",
                "like",
                "affection",
                "valentines",
                "infatuation",
                "kiss"
              ],
              "emoji": "😚"
            },
            {
              "keywords": [
                "face",
                "prank",
                "childish",
                "playful",
                "mischievous",
                "smile",
                "wink",
                "tongue"
              ],
              "emoji": "😜"
            },
            {
              "keywords": [
                "face",
                "goofy",
                "crazy"
              ],
              "emoji": "🤪"
            },
            {
              "keywords": [
                "face",
                "distrust",
                "scepticism",
                "disapproval",
                "disbelief",
                "surprise"
              ],
              "emoji": "🤨"
            },
            {
              "keywords": [
                "face",
                "stuffy",
                "wealthy"
              ],
              "emoji": "🧐"
            },
            {
              "keywords": [
                "face",
                "prank",
                "playful",
                "mischievous",
                "smile",
                "tongue"
              ],
              "emoji": "😝"
            },
            {
              "keywords": [
                "face",
                "prank",
                "childish",
                "playful",
                "mischievous",
                "smile",
                "tongue"
              ],
              "emoji": "😛"
            },
            {
              "keywords": [
                "face",
                "rich",
                "dollar",
                "money"
              ],
              "emoji": "🤑"
            },
            {
              "keywords": [
                "face",
                "nerdy",
                "geek",
                "dork"
              ],
              "emoji": "🤓"
            },
            {
              "keywords": [
                "face",
                "cool",
                "smile",
                "summer",
                "beach",
                "sunglass"
              ],
              "emoji": "😎"
            },
            {
              "keywords": [
                "face",
                "smile",
                "starry",
                "eyes",
                "grinning"
              ],
              "emoji": "🤩"
            },
            {
              "keywords": [
                "face"
              ],
              "emoji": "🤡"
            },
            {
              "keywords": [
                "face",
                "cowgirl",
                "hat"
              ],
              "emoji": "🤠"
            },
            {
              "keywords": [
                "face",
                "smile",
                "hug"
              ],
              "emoji": "🤗"
            },
            {
              "keywords": [
                "face",
                "smile",
                "mean",
                "prank",
                "smug",
                "sarcasm"
              ],
              "emoji": "😏"
            },
            {
              "keywords": [
                "face",
                "hellokitty"
              ],
              "emoji": "😶"
            },
            {
              "keywords": [
                "indifference",
                "meh",
                ":|",
                "neutral"
              ],
              "emoji": "😐"
            },
             {
              "keywords": [
                "face",
                "indifferent",
                "-_-",
                "meh",
                "deadpan"
              ],
              "emoji": "😑"
            },
            {
              "keywords": [
                "indifference",
                "bored",
                "straight face",
                "serious",
                "sarcasm",
                "unimpressed",
                "skeptical",
                "dubious",
                "side_eye"
              ],
              "emoji": "😒"
            },
            {
              "keywords": [
                "face",
                "eyeroll",
                "frustrated"
              ],
              "emoji": "🙄"
            },
            {
              "keywords": [
                "face",
                "hmmm",
                "think",
                "consider"
              ],
              "emoji": "🤔"
            },
             {
              "keywords": [
                "face",
                "lie",
                "pinocchio"
              ],
              "emoji": "🤥"
            },
            {
              "keywords": [
                "face",
                "whoops",
                "shock",
                "surprise"
              ],
              "emoji": "🤭"
            },
            {
              "keywords": [
                "face",
                "quiet",
                "shhh"
              ],
              "emoji": "🤫"
            },
            {
              "keywords": [
                "face",
                "swearing",
                "cursing",
                "cussing",
                "profanity",
                "expletive"
              ],
              "emoji": "🤬"
            },
            {
              "keywords": [
                "face",
                "shocked",
                "mind",
                "blown"
              ],
              "emoji": "🤯"
            },
            {
              "keywords": [
                "face",
                "blush",
                "shy",
                "flattered"
              ],
              "emoji": "😳"
            },
            {
              "keywords": [
                "face",
                "sad",
                "upset",
                "depressed",
                ":("
              ],
              "emoji": "😞"
            },
            {
              "keywords": [
                "face",
                "concern",
                "nervous",
                ":("
              ],
              "emoji": "😟"
            },
            {
              "keywords": [
                "mad",
                "face",
                "annoyed",
                "frustrated"
              ],
              "emoji": "😠"
            },
            {
              "keywords": [
                "angry",
                "mad",
                "hate",
                "despise"
              ],
              "emoji": "😡"
            },
            {
              "keywords": [
                "face",
                "sad",
                "depressed",
                "upset"
              ],
              "emoji": "😔"
            },
            {
              "keywords": [
                "face",
                "indifference",
                "huh",
                "weird",
                "hmmm",
                ":/"
              ],
              "emoji": "😕"
            },
            {
              "keywords": [
                "face",
                "frowning",
                "disappointed",
                "sad",
                "upset"
              ],
              "emoji": "🙁"
            },
            {
              "keywords": [
                "face",
                "sad",
                "upset",
                "frown"
              ],
              "emoji": "☹"
            },
            {
              "keywords": [
                "face",
                "sick",
                "no",
                "upset",
                "oops"
              ],
              "emoji": "😣"
            },
            {
              "keywords": [
                "face",
                "confused",
                "sick",
                "unwell",
                "oops",
                ":S"
              ],
              "emoji": "😖"
            },
            {
              "keywords": [
                "sick",
                "whine",
                "upset",
                "frustrated"
              ],
              "emoji": "😫"
            },
            {
              "keywords": [
                "face",
                "tired",
                "sleepy",
                "sad",
                "frustrated",
                "upset"
              ],
              "emoji": "😩"
            },
             {
              "keywords": [
                "face",
                "begging",
                "mercy"
              ],
              "emoji": "🥺"
            },
             {
              "keywords": [
                "face",
                "gas",
                "phew",
                "proud",
                "pride"
              ],
              "emoji": "😤"
            },
            {
              "keywords": [
                "face",
                "surprise",
                "impressed",
                "wow",
                "whoa",
                ":O"
              ],
              "emoji": "😮"
            },
            {
              "keywords": [
                "face",
                "munch",
                "scared",
                "omg"
              ],
              "emoji": "😱"
            },
            {
              "keywords": [
                "face",
                "scared",
                "terrified",
                "nervous",
                "oops",
                "huh"
              ],
              "emoji": "😨"
            },
            {
              "keywords": [
                "face",
                "nervous",
                "sweat"
              ],
              "emoji": "😰"
            },
            {
              "keywords": [
                "face",
                "woo",
                "shh"
              ],
              "emoji": "😯"
            },
            {
              "keywords": [
                "face",
                "aw",
                "what"
              ],
              "emoji": "😦"
            },
            {
              "keywords": [
                "face",
                "stunned",
                "nervous"
              ],
              "emoji": "😧"
            },
            {
              "keywords": [
                "face",
                "tears",
                "sad",
                "depressed",
                "upset",
                ":'("
              ],
              "emoji": "😢"
            },
            {
              "keywords": [
                "face",
                "phew",
                "sweat",
                "nervous"
              ],
              "emoji": "😥"
            },
            {
              "keywords": [
                "face"
              ],
              "emoji": "🤤"
            },
            {
              "keywords": [
                "face",
                "tired",
                "rest",
                "nap"
              ],
              "emoji": "😪"
            },
             {
              "keywords": [
                "face",
                "hot",
                "sad",
                "tired",
                "exercise"
              ],
              "emoji": "😓"
            },
            {
              "keywords": [
                "face",
                "feverish",
                "heat",
                "red",
                "sweating"
              ],
              "emoji": "🥵"
            },
            {
              "keywords": [
                "face",
                "blue",
                "freezing",
                "frozen",
                "frostbite",
                "icicles"
              ],
              "emoji": "🥶"
            },
            {
              "keywords": [
                "face",
                "cry",
                "tears",
                "sad",
                "upset",
                "depressed"
              ],
              "emoji": "😭"
            },
            {
              "keywords": [
                "spent",
                "unconscious",
                "xox",
                "dizzy"
              ],
              "emoji": "😵"
            },
            {
              "keywords": [
                "face",
                "xox",
                "surprised",
                "poisoned"
              ],
              "emoji": "😲"
            },
            {
              "keywords": [
                "face",
                "sealed",
                "zipper",
                "secret"
              ],
              "emoji": "🤐"
            },
            {
              "keywords": [
                "face",
                "vomit",
                "gross",
                "green",
                "sick",
                "throw up",
                "ill"
              ],
              "emoji": "🤢"
            },
            {
              "keywords": [
                "face",
                "gesundheit",
                "sneeze",
                "sick",
                "allergy"
              ],
              "emoji": "🤧"
            },
            {
              "keywords": [
                "face",
                "sick"
              ],
              "emoji": "🤮"
            },
            {
              "keywords": [
                "face",
                "sick",
                "ill",
                "disease"
              ],
              "emoji": "😷"
            },
            {
              "keywords": [
                "sick",
                "temperature",
                "thermometer",
                "cold",
                "fever"
              ],
              "emoji": "🤒"
            },
            {
              "keywords": [
                "injured",
                "clumsy",
                "bandage",
                "hurt"
              ],
              "emoji": "🤕"
            },
            {
              "keywords": [
                "face",
                "dizzy",
                "intoxicated",
                "tipsy",
                "wavy"
              ],
              "emoji": "🥴"
            },
            {
              "keywords": [
                "face",
                "tired",
                "sleepy",
                "night",
                "zzz"
              ],
              "emoji": "😴"
            },
            {
              "keywords": [
                "sleepy",
                "tired",
                "dream"
              ],
              "emoji": "💤"
            },
            {
              "keywords": [
                "hankey",
                "shitface",
                "fail",
                "turd",
                "shit"
              ],
              "emoji": "💩"
            },
            {
              "keywords": [
                "devil",
                "horns"
              ],
              "emoji": "😈"
            },
            {
              "keywords": [
                "devil",
                "angry",
                "horns"
              ],
              "emoji": "👿"
            },
             {
              "keywords": [
                "monster",
                "red",
                "mask",
                "halloween",
                "scary",
                "creepy",
                "devil",
                "demon",
                "japanese",
                "ogre"
              ],
              "emoji": "👹"
            },
            {
              "keywords": [
                "red",
                "evil",
                "mask",
                "monster",
                "scary",
                "creepy",
                "japanese",
                "goblin"
              ],
              "emoji": "👺"
            },
            {
              "keywords": [
                "dead",
                "skeleton",
                "creepy",
                "death"
              ],
              "emoji": "💀"
            },
            {
              "keywords": [
                "halloween",
                "spooky",
                "scary"
              ],
              "emoji": "👻"
            },
            {
              "keywords": [
                "UFO",
                "paul",
                "weird",
                "outer_space"
              ],
              "emoji": "👽"
            },
            {
              "keywords": [
                "computer",
                "machine",
                "bot"
              ],
              "emoji": "🤖"
            },
            {
              "keywords": [
                "animal",
                "cats",
                "happy",
                "smile"
              ],
              "emoji": "😺"
            },
            {
              "keywords": [
                "animal",
                "cats",
                "smile"
              ],
              "emoji": "😸"
            },
            {
              "keywords": [
                "animal",
                "cats",
                "haha",
                "happy",
                "tears"
              ],
              "emoji": "😹"
            },
            {
              "keywords": [
                "animal",
                "love",
                "like",
                "affection",
                "cats",
                "valentines",
                "heart"
              ],
              "emoji": "😻"
            },
            {
              "keywords": [
                "animal",
                "cats",
                "smirk"
              ],
              "emoji": "😼"
            },
            {
              "keywords": [
                "animal",
                "cats",
                "kiss"
              ],
              "emoji": "😽"
            },
            {
              "keywords": [
                "animal",
                "cats",
                "munch",
                "scared",
                "scream"
              ],
              "emoji": "🙀"
            },
            {
              "keywords": [
                "animal",
                "tears",
                "weep",
                "sad",
                "cats",
                "upset",
                "cry"
              ],
              "emoji": "😿"
            },
            {
              "keywords": [
                "animal",
                "cats"
              ],
              "emoji": "😾"
            },
            {
              "keywords": [
                "hands",
                "gesture",
                "cupped",
                "prayer"
              ],
              "emoji": "🤲"
            },
            {
              "keywords": [
                "gesture",
                "hooray",
                "yea",
                "celebration",
                "hands"
              ],
              "emoji": "🙌"
            },
            {
              "keywords": [
                "hands",
                "praise",
                "applause",
                "congrats",
                "yay"
              ],
              "emoji": "👏"
            },
            {
              "keywords": [
                "hands",
                "gesture",
                "goodbye",
                "solong",
                "farewell",
                "hello",
                "hi",
                "palm"
              ],
              "emoji": "👋"
            },
            {
              "keywords": [
                "hands",
                "gesture"
              ],
              "emoji": "🤙"
            },
            {
              "keywords": [
                "thumbsup",
                "yes",
                "awesome",
                "good",
                "agree",
                "accept",
                "cool",
                "hand",
                "like"
              ],
              "emoji": "👍"
            },
            {
              "keywords": [
                "thumbsdown",
                "no",
                "dislike",
                "hand"
              ],
              "emoji": "👎"
            },
            {
              "keywords": [
                "angry",
                "violence",
                "fist",
                "hit",
                "attack",
                "hand"
              ],
              "emoji": "👊"
            },
            {
              "keywords": [
                "fingers",
                "hand",
                "grasp"
              ],
              "emoji": "✊"
            },
            {
              "keywords": [
                "hand",
                "fistbump"
              ],
              "emoji": "🤛"
            },
            {
              "keywords": [
                "hand",
                "fistbump"
              ],
              "emoji": "🤜"
            },
            {
              "keywords": [
                "fingers",
                "ohyeah",
                "hand",
                "peace",
                "victory",
                "two"
              ],
              "emoji": "✌"
            },
            {
              "keywords": [
                "fingers",
                "limbs",
                "perfect",
                "ok",
                "okay"
              ],
              "emoji": "👌"
            },
            {
              "keywords": [
                "fingers",
                "stop",
                "highfive",
                "palm",
                "ban"
              ],
              "emoji": "✋"
            },
            {
              "keywords": [
                "fingers",
                "raised",
                "backhand"
              ],
              "emoji": "🤚"
            },
            {
              "keywords": [
                "fingers",
                "butterfly",
                "hands",
                "open"
              ],
              "emoji": "👐"
            },
            {
              "keywords": [
                "arm",
                "flex",
                "hand",
                "summer",
                "strong",
                "biceps"
              ],
              "emoji": "💪"
            },
            {
              "keywords": [
                "please",
                "hope",
                "wish",
                "namaste",
                "highfive"
              ],
              "emoji": "🙏"
            },
            {
              "keywords": [
                "kick",
                "stomp"
              ],
              "emoji": "🦶"
            },
            {
              "keywords": [
                "kick",
                "limb"
              ],
              "emoji": "🦵"
            },
            {
              "keywords": [
                "agreement",
                "shake"
              ],
              "emoji": "🤝"
            },
            {
              "keywords": [
                "hand",
                "fingers",
                "direction",
                "up"
              ],
              "emoji": "☝"
            },
             {
              "keywords": [
                "fingers",
                "hand",
                "direction",
                "up"
              ],
              "emoji": "👆"
            },
            {
              "keywords": [
                "fingers",
                "hand",
                "direction",
                "down"
              ],
              "emoji": "👇"
            },
            {
              "keywords": [
                "direction",
                "fingers",
                "hand",
                "left"
              ],
              "emoji": "👈"
            },
            {
              "keywords": [
                "fingers",
                "hand",
                "direction",
                "right"
              ],
              "emoji": "👉"
            },
            {
              "keywords": [
                "hand",
                "fingers",
                "rude",
                "middle",
                "flipping"
              ],
              "emoji": "🖕"
            },
            {
              "keywords": [
                "hand",
                "fingers",
                "palm"
              ],
              "emoji": "🖐"
            },
            {
              "keywords": [
                "hand",
                "fingers",
                "gesture"
              ],
              "emoji": "🤟"
            },
            {
              "keywords": [
                "hand",
                "fingers",
                "evil_eye",
                "sign_of_horns",
                "rock_on"
              ],
              "emoji": "🤘"
            },
            {
              "keywords": [
                "good",
                "lucky"
              ],
              "emoji": "🤞"
            },
            {
              "keywords": [
                "hand",
                "fingers",
                "spock",
                "star trek"
              ],
              "emoji": "🖖"
            },
            {
              "keywords": [
                "lower_left_ballpoint_pen",
                "stationery",
                "write",
                "compose"
              ],
              "emoji": "✍"
            },
             {
              "keywords": [
                "camera",
                "phone"
              ],
              "emoji": "🤳"
            },
            {
              "keywords": [
                "beauty",
                "manicure",
                "finger",
                "fashion",
                "nail"
              ],
              "emoji": "💅"
            },
            {
              "keywords": [
                "mouth",
                "kiss"
              ],
              "emoji": "👄"
            },
            {
              "keywords": [
                "teeth",
                "dentist"
              ],
              "emoji": "🦷"
            },
            {
              "keywords": [
                "mouth",
                "playful"
              ],
              "emoji": "👅"
            },
            {
              "keywords": [
                "face",
                "hear",
                "sound",
                "listen"
              ],
              "emoji": "👂"
            },
            {
              "keywords": [
                "smell",
                "sniff"
              ],
              "emoji": "👃"
            },
            {
              "keywords": [
                "face",
                "look",
                "see",
                "watch",
                "stare"
              ],
              "emoji": "👁"
            },
            {
              "keywords": [
                "look",
                "watch",
                "stalk",
                "peek",
                "see"
              ],
              "emoji": "👀"
            },
            {
              "keywords": [
                "smart",
                "intelligent"
              ],
              "emoji": "🧠"
            },
             {
              "keywords": [
                "user",
                "person",
                "human"
              ],
              "emoji": "👤"
            },
            {
              "keywords": [
                "user",
                "person",
                "human",
                "group",
                "team"
              ],
              "emoji": "👥"
            },
            {
              "keywords": [
                "user",
                "person",
                "human",
                "sing",
                "say",
                "talk"
              ],
              "emoji": "🗣"
            },
            {
              "keywords": [
                "child",
                "boy",
                "girl",
                "toddler"
              ],
              "emoji": "👶"
            },
            {
              "keywords": [
                "gender-neutral",
                "young"
              ],
              "emoji": "🧒"
            },
            {
              "keywords": [
                "man",
                "male",
                "guy",
                "teenager"
              ],
              "emoji": "👦"
            },
             {
              "keywords": [
                "female",
                "woman",
                "teenager"
              ],
              "emoji": "👧"
            },
            {
              "keywords": [
                "gender-neutral",
                "person"
              ],
              "emoji": "🧑"
            },
            {
              "keywords": [
                "mustache",
                "father",
                "dad",
                "guy",
                "classy",
                "sir",
                "moustache"
              ],
              "emoji": "👨"
            },
            {
              "keywords": [
                "female",
                "girls",
                "lady"
              ],
              "emoji": "👩"
            },
             {
              "keywords": [
                "woman",
                "female",
                "girl",
                "blonde",
                "person"
              ],
              "emoji": "👱‍♀️"
            },
            {
              "keywords": [
                "man",
                "male",
                "boy",
                "blonde",
                "guy",
                "person"
              ],
              "emoji": "👱"
            },
             {
              "keywords": [
                "person",
                "bewhiskered"
              ],
              "emoji": "🧔"
            },
            {
              "keywords": [
                "human",
                "elder",
                "senior",
                "gender-neutral"
              ],
              "emoji": "🧓"
            },
            {
              "keywords": [
                "human",
                "male",
                "men",
                "old",
                "elder",
                "senior"
              ],
              "emoji": "👴"
            },
            {
              "keywords": [
                "human",
                "female",
                "women",
                "lady",
                "old",
                "elder",
                "senior"
              ],
              "emoji": "👵"
            },
             {
              "keywords": [
                "male",
                "boy",
                "chinese"
              ],
              "emoji": "👲"
            },
            {
              "keywords": [
                "female",
                "hijab",
                "mantilla",
                "tichel"
              ],
              "emoji": "🧕"
            },
            {
              "keywords": [
                "female",
                "indian",
                "hinduism",
                "arabs",
                "woman"
              ],
              "emoji": "👳‍♀️"
            },
             {
              "keywords": [
                "male",
                "indian",
                "hinduism",
                "arabs"
              ],
              "emoji": "👳"
            },
            {
              "keywords": [
                "woman",
                "police",
                "law",
                "legal",
                "enforcement",
                "arrest",
                "911",
                "female"
              ],
              "emoji": "👮‍♀️"
            },
            {
              "keywords": [
                "man",
                "police",
                "law",
                "legal",
                "enforcement",
                "arrest",
                "911"
              ],
              "emoji": "👮"
            },
            {
              "keywords": [
                "female",
                "human",
                "wip",
                "build",
                "construction",
                "worker",
                "labor",
                "woman"
              ],
              "emoji": "👷‍♀️"
            },
            {
              "keywords": [
                "male",
                "human",
                "wip",
                "guy",
                "build",
                "construction",
                "worker",
                "labor"
              ],
              "emoji": "👷"
            },
            {
              "keywords": [
                "uk",
                "gb",
                "british",
                "female",
                "royal",
                "woman"
              ],
              "emoji": "💂‍♀️"
            },
            {
              "keywords": [
                "uk",
                "gb",
                "british",
                "male",
                "guy",
                "royal"
              ],
              "emoji": "💂"
            },
            {
              "keywords": [
                "human",
                "spy",
                "detective",
                "female",
                "woman"
              ],
              "emoji": "🕵️‍♀️"
            },
            {
              "keywords": [
                "human",
                "spy",
                "detective"
              ],
              "emoji": "🕵"
            },
            {
              "keywords": [
                "doctor",
                "nurse",
                "therapist",
                "healthcare",
                "woman",
                "human"
              ],
              "emoji": "👩‍⚕️"
            },
            {
              "keywords": [
                "doctor",
                "nurse",
                "therapist",
                "healthcare",
                "man",
                "human"
              ],
              "emoji": "👨‍⚕️"
            },
            {
              "keywords": [
                "rancher",
                "gardener",
                "woman",
                "human"
              ],
              "emoji": "👩‍🌾"
            },
            {
              "keywords": [
                "rancher",
                "gardener",
                "man",
                "human"
              ],
              "emoji": "👨‍🌾"
            },
            {
              "keywords": [
                "chef",
                "woman",
                "human"
              ],
              "emoji": "👩‍🍳"
            },
            {
              "keywords": [
                "chef",
                "man",
                "human"
              ],
              "emoji": "👨‍🍳"
            },
            {
              "keywords": [
                "graduate",
                "woman",
                "human"
              ],
              "emoji": "👩‍🎓"
            },
             {
              "keywords": [
                "graduate",
                "man",
                "human"
              ],
              "emoji": "👨‍🎓"
            },
             {
              "keywords": [
                "rockstar",
                "entertainer",
                "woman",
                "human"
              ],
              "emoji": "👩‍🎤"
            },
             {
              "keywords": [
                "rockstar",
                "entertainer",
                "man",
                "human"
              ],
              "emoji": "👨‍🎤"
            },
            {
              "keywords": [
                "instructor",
                "professor",
                "woman",
                "human"
              ],
              "emoji": "👩‍🏫"
            },
            {
              "keywords": [
                "instructor",
                "professor",
                "man",
                "human"
              ],
              "emoji": "👨‍🏫"
            },
            {
              "keywords": [
                "assembly",
                "industrial",
                "woman",
                "human"
              ],
              "emoji": "👩‍🏭"
            },
            {
              "keywords": [
                "assembly",
                "industrial",
                "man",
                "human"
              ],
              "emoji": "👨‍🏭"
            },
            {
              "keywords": [
                "coder",
                "developer",
                "engineer",
                "programmer",
                "software",
                "woman",
                "human",
                "laptop",
                "computer"
              ],
              "emoji": "👩‍💻"
            },
            {
              "keywords": [
                "coder",
                "developer",
                "engineer",
                "programmer",
                "software",
                "man",
                "human",
                "laptop",
                "computer"
              ],
              "emoji": "👨‍💻"
            },
            {
              "keywords": [
                "business",
                "manager",
                "woman",
                "human"
              ],
              "emoji": "👩‍💼"
            },
            {
              "keywords": [
                "business",
                "manager",
                "man",
                "human"
              ],
              "emoji": "👨‍💼"
            },
            {
              "keywords": [
                "plumber",
                "woman",
                "human",
                "wrench"
              ],
              "emoji": "👩‍🔧"
            },
            {
              "keywords": [
                "plumber",
                "man",
                "human",
                "wrench"
              ],
              "emoji": "👨‍🔧"
            },
            {
              "keywords": [
                "biologist",
                "chemist",
                "engineer",
                "physicist",
                "woman",
                "human"
              ],
              "emoji": "👩‍🔬"
            },
            {
              "keywords": [
                "biologist",
                "chemist",
                "engineer",
                "physicist",
                "man",
                "human"
              ],
              "emoji": "👨‍🔬"
            },
            {
              "keywords": [
                "painter",
                "woman",
                "human"
              ],
              "emoji": "👩‍🎨"
            },
            {
              "keywords": [
                "painter",
                "man",
                "human"
              ],
              "emoji": "👨‍🎨"
            },
            {
              "keywords": [
                "fireman",
                "woman",
                "human"
              ],
              "emoji": "👩‍🚒"
            },
            {
              "keywords": [
                "fireman",
                "man",
                "human"
              ],
              "emoji": "👨‍🚒"
            },
            {
              "keywords": [
                "aviator",
                "plane",
                "woman",
                "human"
              ],
              "emoji": "👩‍✈️"
            },
             {
              "keywords": [
                "aviator",
                "plane",
                "man",
                "human"
              ],
              "emoji": "👨‍✈️"
            },
            {
              "keywords": [
                "space",
                "rocket",
                "woman",
                "human"
              ],
              "emoji": "👩‍🚀"
            },
            {
              "keywords": [
                "space",
                "rocket",
                "man",
                "human"
              ],
              "emoji": "👨‍🚀"
            },
            {
              "keywords": [
                "justice",
                "court",
                "woman",
                "human"
              ],
              "emoji": "👩‍⚖️"
            },
            {
              "keywords": [
                "justice",
                "court",
                "man",
                "human"
              ],
              "emoji": "👨‍⚖️"
            },
            {
              "keywords": [
                "woman",
                "female",
                "good",
                "heroine",
                "superpowers"
              ],
              "emoji": "🦸‍♀️"
            },
             {
              "keywords": [
                "man",
                "male",
                "good",
                "hero",
                "superpowers"
              ],
              "emoji": "🦸‍♂️"
            },
            {
              "keywords": [
                "woman",
                "female",
                "evil",
                "bad",
                "criminal",
                "heroine",
                "superpowers"
              ],
              "emoji": "🦹‍♀️"
            },
            {
              "keywords": [
                "man",
                "male",
                "evil",
                "bad",
                "criminal",
                "hero",
                "superpowers"
              ],
              "emoji": "🦹‍♂️"
            },
            {
              "keywords": [
                "woman",
                "female",
                "xmas",
                "mother christmas"
              ],
              "emoji": "🤶"
            },
            {
              "keywords": [
                "festival",
                "man",
                "male",
                "xmas",
                "father christmas"
              ],
              "emoji": "🎅"
            },
            {
              "keywords": [
                "woman",
                "female",
                "mage",
                "witch"
              ],
              "emoji": "🧙‍♀️"
            },
            {
              "keywords": [
                "man",
                "male",
                "mage",
                "sorcerer"
              ],
              "emoji": "🧙‍♂️"
            },
            {
              "keywords": [
                "woman",
                "female"
              ],
              "emoji": "🧝‍♀️"
            },
            {
              "keywords": [
                "man",
                "male"
              ],
              "emoji": "🧝‍♂️"
            },
             {
              "keywords": [
                "woman",
                "female"
              ],
              "emoji": "🧛‍♀️"
            },
            {
              "keywords": [
                "man",
                "male",
                "dracula"
              ],
              "emoji": "🧛‍♂️"
            },
            {
              "keywords": [
                "woman",
                "female",
                "undead",
                "walking dead"
              ],
              "emoji": "🧟‍♀️"
            },
             {
              "keywords": [
                "man",
                "male",
                "dracula",
                "undead",
                "walking dead"
              ],
              "emoji": "🧟‍♂️"
            },
             {
              "keywords": [
                "woman",
                "female"
              ],
              "emoji": "🧞‍♀️"
            },
             {
              "keywords": [
                "man",
                "male"
              ],
              "emoji": "🧞‍♂️"
            },
            {
              "keywords": [
                "woman",
                "female",
                "merwoman",
                "ariel"
              ],
              "emoji": "🧜‍♀️"
            },
            {
              "keywords": [
                "man",
                "male",
                "triton"
              ],
              "emoji": "🧜‍♂️"
            },
            {
              "keywords": [
                "woman",
                "female"
              ],
              "emoji": "🧚‍♀️"
            },
            {
              "keywords": [
                "man",
                "male"
              ],
              "emoji": "🧚‍♂️"
            },
             {
              "keywords": [
                "heaven",
                "wings",
                "halo"
              ],
              "emoji": "👼"
            },
            {
              "keywords": [
                "baby"
              ],
              "emoji": "🤰"
            },
             {
              "keywords": [
                "nursing",
                "baby"
              ],
              "emoji": "🤱"
            },
            {
              "keywords": [
                "girl",
                "woman",
                "female",
                "blond",
                "crown",
                "royal",
                "queen"
              ],
              "emoji": "👸"
            },
            {
              "keywords": [
                "boy",
                "man",
                "male",
                "crown",
                "royal",
                "king"
              ],
              "emoji": "🤴"
            },
            {
              "keywords": [
                "couple",
                "marriage",
                "wedding",
                "woman",
                "bride"
              ],
              "emoji": "👰"
            },
            {
              "keywords": [
                "couple",
                "marriage",
                "wedding",
                "groom"
              ],
              "emoji": "🤵"
            },
            {
              "keywords": [
                "woman",
                "walking",
                "exercise",
                "race",
                "running",
                "female"
              ],
              "emoji": "🏃‍♀️"
            },
            {
              "keywords": [
                "man",
                "walking",
                "exercise",
                "race",
                "running"
              ],
              "emoji": "🏃"
            },
            {
              "keywords": [
                "human",
                "feet",
                "steps",
                "woman",
                "female"
              ],
              "emoji": "🚶‍♀️"
            },
            {
              "keywords": [
                "human",
                "feet",
                "steps"
              ],
              "emoji": "🚶"
            },
            {
              "keywords": [
                "female",
                "girl",
                "woman",
                "fun"
              ],
              "emoji": "💃"
            },
            {
              "keywords": [
                "male",
                "boy",
                "fun",
                "dancer"
              ],
              "emoji": "🕺"
            },
            {
              "keywords": [
                "female",
                "bunny",
                "women",
                "girls"
              ],
              "emoji": "👯"
            },
             {
              "keywords": [
                "male",
                "bunny",
                "men",
                "boys"
              ],
              "emoji": "👯‍♂️"
            },
            {
              "keywords": [
                "pair",
                "people",
                "human",
                "love",
                "date",
                "dating",
                "like",
                "affection",
                "valentines",
                "marriage"
              ],
              "emoji": "👫"
            },
            {
              "keywords": [
                "pair",
                "couple",
                "love",
                "like",
                "bromance",
                "friendship",
                "people",
                "human"
              ],
              "emoji": "👬"
            },
            {
              "keywords": [
                "pair",
                "friendship",
                "couple",
                "love",
                "like",
                "female",
                "people",
                "human"
              ],
              "emoji": "👭"
            },
            {
              "keywords": [
                "woman",
                "female",
                "girl"
              ],
              "emoji": "🙇‍♀️"
            },
            {
              "keywords": [
                "man",
                "male",
                "boy"
              ],
              "emoji": "🙇"
            },
            {
              "keywords": [
                "man",
                "male",
                "boy",
                "disbelief"
              ],
              "emoji": "🤦‍♂️"
            },
            {
              "keywords": [
                "woman",
                "female",
                "girl",
                "disbelief"
              ],
              "emoji": "🤦‍♀️"
            },
            {
              "keywords": [
                "woman",
                "female",
                "girl",
                "confused",
                "indifferent",
                "doubt"
              ],
              "emoji": "🤷"
            },
            {
              "keywords": [
                "man",
                "male",
                "boy",
                "confused",
                "indifferent",
                "doubt"
              ],
              "emoji": "🤷‍♂️"
            },
            {
              "keywords": [
                "female",
                "girl",
                "woman",
                "human",
                "information"
              ],
              "emoji": "💁"
            },
            {
              "keywords": [
                "male",
                "boy",
                "man",
                "human",
                "information"
              ],
              "emoji": "💁‍♂️"
            },
            {
              "keywords": [
                "female",
                "girl",
                "woman",
                "nope"
              ],
              "emoji": "🙅"
            },
            {
              "keywords": [
                "male",
                "boy",
                "man",
                "nope"
              ],
              "emoji": "🙅‍♂️"
            },
            {
              "keywords": [
                "women",
                "girl",
                "female",
                "pink",
                "human",
                "woman"
              ],
              "emoji": "🙆"
            },
            {
              "keywords": [
                "men",
                "boy",
                "male",
                "blue",
                "human",
                "man"
              ],
              "emoji": "🙆‍♂️"
            },
            {
              "keywords": [
                "female",
                "girl",
                "woman"
              ],
              "emoji": "🙋"
            },
            {
              "keywords": [
                "male",
                "boy",
                "man"
              ],
              "emoji": "🙋‍♂️"
            },
             {
              "keywords": [
                "female",
                "girl",
                "woman"
              ],
              "emoji": "🙎"
            },
             {
              "keywords": [
                "male",
                "boy",
                "man"
              ],
              "emoji": "🙎‍♂️"
            },
            {
              "keywords": [
                "female",
                "girl",
                "woman",
                "sad",
                "depressed",
                "discouraged",
                "unhappy"
              ],
              "emoji": "🙍"
            },
             {
              "keywords": [
                "male",
                "boy",
                "man",
                "sad",
                "depressed",
                "discouraged",
                "unhappy"
              ],
              "emoji": "🙍‍♂️"
            },
             {
              "keywords": [
                "female",
                "girl",
                "woman"
              ],
              "emoji": "💇"
            },
            {
              "keywords": [
                "male",
                "boy",
                "man"
              ],
              "emoji": "💇‍♂️"
            },
            {
              "keywords": [
                "female",
                "girl",
                "woman",
                "head"
              ],
              "emoji": "💆"
            },
            {
              "keywords": [
                "male",
                "boy",
                "man",
                "head"
              ],
              "emoji": "💆‍♂️"
            },
            {
              "keywords": [
                "female",
                "woman",
                "spa",
                "steamroom",
                "sauna"
              ],
              "emoji": "🧖‍♀️"
            },
            {
              "keywords": [
                "male",
                "man",
                "spa",
                "steamroom",
                "sauna"
              ],
              "emoji": "🧖‍♂️"
            },
             {
              "keywords": [
                "pair",
                "love",
                "like",
                "affection",
                "human",
                "dating",
                "valentines",
                "marriage"
              ],
              "emoji": "💑"
            },
            {
              "keywords": [
                "pair",
                "love",
                "like",
                "affection",
                "human",
                "dating",
                "valentines",
                "marriage"
              ],
              "emoji": "👩‍❤️‍👩"
            },
             {
              "keywords": [
                "pair",
                "love",
                "like",
                "affection",
                "human",
                "dating",
                "valentines",
                "marriage"
              ],
              "emoji": "👨‍❤️‍👨"
            },
            {
              "keywords": [
                "pair",
                "valentines",
                "love",
                "like",
                "dating",
                "marriage"
              ],
              "emoji": "💏"
            },
             {
              "keywords": [
                "pair",
                "valentines",
                "love",
                "like",
                "dating",
                "marriage"
              ],
              "emoji": "👩‍❤️‍💋‍👩"
            },
            {
              "keywords": [
                "pair",
                "valentines",
                "love",
                "like",
                "dating",
                "marriage"
              ],
              "emoji": "👨‍❤️‍💋‍👨"
            },
            {
              "keywords": [
                "home",
                "parents",
                "child",
                "mom",
                "dad",
                "father",
                "mother",
                "people",
                "human"
              ],
              "emoji": "👪"
            },
            {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "child"
              ],
              "emoji": "👨‍👩‍👧"
            },
            {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👨‍👩‍👧‍👦"
            },
            {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👨‍👩‍👦‍👦"
            },
             {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👨‍👩‍👧‍👧"
            },
            {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👩‍👩‍👦"
            },
            {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👩‍👩‍👧"
            },
             {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👩‍👩‍👧‍👦"
            },
            {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👩‍👩‍👦‍👦"
            },
            {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👩‍👩‍👧‍👧"
            },
            {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👨‍👨‍👦"
            },
            {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👨‍👨‍👧"
            },
            {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👨‍👨‍👧‍👦"
            },
            {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👨‍👨‍👦‍👦"
            },
            {
              "keywords": [
                "home",
                "parents",
                "people",
                "human",
                "children"
              ],
              "emoji": "👨‍👨‍👧‍👧"
            },
            {
              "keywords": [
                "home",
                "parent",
                "people",
                "human",
                "child"
              ],
              "emoji": "👩‍👦"
            },
            {
              "keywords": [
                "home",
                "parent",
                "people",
                "human",
                "child"
              ],
              "emoji": "👩‍👧"
            },
             {
              "keywords": [
                "home",
                "parent",
                "people",
                "human",
                "children"
              ],
              "emoji": "👩‍👧‍👦"
            },
            {
              "keywords": [
                "home",
                "parent",
                "people",
                "human",
                "children"
              ],
              "emoji": "👩‍👦‍👦"
            },
             {
              "keywords": [
                "home",
                "parent",
                "people",
                "human",
                "children"
              ],
              "emoji": "👩‍👧‍👧"
            },
             {
              "keywords": [
                "home",
                "parent",
                "people",
                "human",
                "child"
              ],
              "emoji": "👨‍👦"
            },
             {
              "keywords": [
                "home",
                "parent",
                "people",
                "human",
                "child"
              ],
              "emoji": "👨‍👧"
            },
            {
              "keywords": [
                "home",
                "parent",
                "people",
                "human",
                "children"
              ],
              "emoji": "👨‍👧‍👦"
            },
             {
              "keywords": [
                "home",
                "parent",
                "people",
                "human",
                "children"
              ],
              "emoji": "👨‍👦‍👦"
            },
             {
              "keywords": [
                "home",
                "parent",
                "people",
                "human",
                "children"
              ],
              "emoji": "👨‍👧‍👧"
            },
            {
              "keywords": [
                "ball",
                "crochet",
                "knit"
              ],
              "emoji": "🧶"
            },
            {
              "keywords": [
                "needle",
                "sewing",
                "spool",
                "string"
              ],
              "emoji": "🧵"
            },
            {
              "keywords": [
                "jacket"
              ],
              "emoji": "🧥"
            },
             {
              "keywords": [
                "doctor",
                "experiment",
                "scientist",
                "chemist"
              ],
              "emoji": "🥼"
            },
            {
              "keywords": [
                "fashion",
                "shopping_bags",
                "female"
              ],
              "emoji": "👚"
            },
            {
              "keywords": [
                "fashion",
                "cloth",
                "casual",
                "shirt",
                "tee"
              ],
              "emoji": "👕"
            },
            {
              "keywords": [
                "fashion",
                "shopping"
              ],
              "emoji": "👖"
            },
            {
              "keywords": [
                "shirt",
                "suitup",
                "formal",
                "fashion",
                "cloth",
                "business"
              ],
              "emoji": "👔"
            },
            {
              "keywords": [
                "clothes",
                "fashion",
                "shopping"
              ],
              "emoji": "👗"
            },
             {
              "keywords": [
                "swimming",
                "female",
                "woman",
                "girl",
                "fashion",
                "beach",
                "summer"
              ],
              "emoji": "👙"
            },
            {
              "keywords": [
                "dress",
                "fashion",
                "women",
                "female",
                "japanese"
              ],
              "emoji": "👘"
            },
             {
              "keywords": [
                "female",
                "girl",
                "fashion",
                "woman"
              ],
              "emoji": "💄"
            },
            {
              "keywords": [
                "face",
                "lips",
                "love",
                "like",
                "affection",
                "valentines"
              ],
              "emoji": "💋"
            },
            {
              "keywords": [
                "feet",
                "tracking",
                "walking",
                "beach"
              ],
              "emoji": "👣"
            },
             {
              "keywords": [
                "ballet",
                "slip-on",
                "slipper"
              ],
              "emoji": "🥿"
            },
             {
              "keywords": [
                "fashion",
                "shoes",
                "female",
                "pumps",
                "stiletto"
              ],
              "emoji": "👠"
            },
             {
              "keywords": [
                "shoes",
                "fashion",
                "flip flops"
              ],
              "emoji": "👡"
            },
            {
              "keywords": [
                "shoes",
                "fashion"
              ],
              "emoji": "👢"
            },
            {
              "keywords": [
                "fashion",
                "male"
              ],
              "emoji": "👞"
            },
             {
              "keywords": [
                "shoes",
                "sports",
                "sneakers"
              ],
              "emoji": "👟"
            },
             {
              "keywords": [
                "backpacking",
                "camping",
                "hiking"
              ],
              "emoji": "🥾"
            },
            {
              "keywords": [
                "stockings",
                "clothes"
              ],
              "emoji": "🧦"
            },
             {
              "keywords": [
                "hands",
                "winter",
                "clothes"
              ],
              "emoji": "🧤"
            },
             {
              "keywords": [
                "neck",
                "winter",
                "clothes"
              ],
              "emoji": "🧣"
            },
             {
              "keywords": [
                "fashion",
                "accessories",
                "female",
                "lady",
                "spring"
              ],
              "emoji": "👒"
            },
            {
              "keywords": [
                "magic",
                "gentleman",
                "classy",
                "circus"
              ],
              "emoji": "🎩"
            },
             {
              "keywords": [
                "cap",
                "baseball"
              ],
              "emoji": "🧢"
            },
             {
              "keywords": [
                "construction",
                "build"
              ],
              "emoji": "⛑"
            },
            {
              "keywords": [
                "school",
                "college",
                "degree",
                "university",
                "graduation",
                "cap",
                "hat",
                "legal",
                "learn",
                "education"
              ],
              "emoji": "🎓"
            },
            {
              "keywords": [
                "king",
                "kod",
                "leader",
                "royalty",
                "lord"
              ],
              "emoji": "👑"
            },
            {
              "keywords": [
                "student",
                "education",
                "bag",
                "backpack"
              ],
              "emoji": "🎒"
            },
            {
              "keywords": [
                "packing",
                "travel"
              ],
              "emoji": "🧳"
            },
             {
              "keywords": [
                "bag",
                "accessories",
                "shopping"
              ],
              "emoji": "👝"
            },
            {
              "keywords": [
                "fashion",
                "accessories",
                "money",
                "sales",
                "shopping"
              ],
              "emoji": "👛"
            },
            {
              "keywords": [
                "fashion",
                "accessory",
                "accessories",
                "shopping"
              ],
              "emoji": "👜"
            },
            {
              "keywords": [
                "business",
                "documents",
                "work",
                "law",
                "legal",
                "job",
                "career"
              ],
              "emoji": "💼"
            },
             {
              "keywords": [
                "fashion",
                "accessories",
                "eyesight",
                "nerdy",
                "dork",
                "geek"
              ],
              "emoji": "👓"
            },
            {
              "keywords": [
                "face",
                "cool",
                "accessories"
              ],
              "emoji": "🕶"
            },
            {
              "keywords": [
                "eyes",
                "protection",
                "safety"
              ],
              "emoji": "🥽"
            },
            {
              "keywords": [
                "wedding",
                "propose",
                "marriage",
                "valentines",
                "diamond",
                "fashion",
                "jewelry",
                "gem",
                "engagement"
              ],
              "emoji": "💍"
            },
             {
              "keywords": [
                "weather",
                "rain",
                "drizzle"
              ],
              "emoji": "🌂"
            }
          ]
      },
    
      {
          "id": "animals_and_nature",
          "name": "Animals & Nature",
          "symbol": "messages-emoji-keyboard-animals.png",
          "emojis": [
            {
              "keywords": [
                "animal",
                "friend",
                "nature",
                "woof",
                "puppy",
                "pet",
                "faithful"
              ],
              "emoji": "🐶"
            },
            {
              "keywords": [
                "animal",
                "meow",
                "nature",
                "pet",
                "kitten"
              ],
              "emoji": "🐱"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "cheese_wedge",
                "rodent"
              ],
              "emoji": "🐭"
            },
            {
              "keywords": [
                "animal",
                "nature"
              ],
              "emoji": "🐹"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "pet",
                "spring",
                "magic",
                "bunny"
              ],
              "emoji": "🐰"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "face"
              ],
              "emoji": "🦊"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "wild"
              ],
              "emoji": "🐻"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "panda"
              ],
              "emoji": "🐼"
            },
            {
              "keywords": [
                "animal",
                "nature"
              ],
              "emoji": "🐨"
            },
            {
              "keywords": [
                "animal",
                "cat",
                "danger",
                "wild",
                "nature",
                "roar"
              ],
              "emoji": "🐯"
            },
            {
              "keywords": [
                "animal",
                "nature"
              ],
              "emoji": "🦁"
            },
            {
              "keywords": [
                "beef",
                "ox",
                "animal",
                "nature",
                "moo",
                "milk"
              ],
              "emoji": "🐮"
            },
            {
              "keywords": [
                "animal",
                "oink",
                "nature"
              ],
              "emoji": "🐷"
            },
            {
              "keywords": [
                "animal",
                "oink"
              ],
              "emoji": "🐽"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "croak",
                "toad"
              ],
              "emoji": "🐸"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "ocean",
                "sea"
              ],
              "emoji": "🦑"
            },
             {
              "keywords": [
                "animal",
                "creature",
                "ocean",
                "sea",
                "nature",
                "beach"
              ],
              "emoji": "🐙"
            },
            {
              "keywords": [
                "animal",
                "ocean",
                "nature",
                "seafood"
              ],
              "emoji": "🦐"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "circus"
              ],
              "emoji": "🐵"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "circus"
              ],
              "emoji": "🦍"
            },
            {
              "keywords": [
                "monkey",
                "animal",
                "nature",
                "haha"
              ],
              "emoji": "🙈"
            },
            {
              "keywords": [
                "animal",
                "monkey",
                "nature"
              ],
              "emoji": "🙉"
            },
            {
              "keywords": [
                "monkey",
                "animal",
                "nature",
                "omg"
              ],
              "emoji": "🙊"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "banana",
                "circus"
              ],
              "emoji": "🐒"
            },
             {
              "keywords": [
                "animal",
                "cluck",
                "nature",
                "bird"
              ],
              "emoji": "🐔"
            },
             {
              "keywords": [
                "animal",
                "nature"
              ],
              "emoji": "🐧"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "fly",
                "tweet",
                "spring"
              ],
              "emoji": "🐦"
            },
            {
              "keywords": [
                "animal",
                "chicken",
                "bird"
              ],
              "emoji": "🐤"
            },
            {
              "keywords": [
                "animal",
                "chicken",
                "egg",
                "born",
                "baby",
                "bird"
              ],
              "emoji": "🐣"
            },
             {
              "keywords": [
                "animal",
                "chicken",
                "baby",
                "bird"
              ],
              "emoji": "🐥"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "bird",
                "mallard"
              ],
              "emoji": "🦆"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "bird"
              ],
              "emoji": "🦅"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "bird",
                "hoot"
              ],
              "emoji": "🦉"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "blind",
                "vampire"
              ],
              "emoji": "🦇"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "wild"
              ],
              "emoji": "🐺"
            },
            {
              "keywords": [
                "animal",
                "nature"
              ],
              "emoji": "🐗"
            },
             {
              "keywords": [
                "animal",
                "brown",
                "nature"
              ],
              "emoji": "🐴"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "mystical"
              ],
              "emoji": "🦄"
            },
             {
              "keywords": [
                "animal",
                "insect",
                "nature",
                "bug",
                "spring",
                "honey"
              ],
              "emoji": "🐝"
            },
            {
              "keywords": [
                "animal",
                "insect",
                "nature",
                "worm"
              ],
              "emoji": "🐛"
            },
            {
              "keywords": [
                "animal",
                "insect",
                "nature",
                "caterpillar"
              ],
              "emoji": "🦋"
            },
            {
              "keywords": [
                "slow",
                "animal",
                "shell"
              ],
              "emoji": "🐌"
            },
            {
              "keywords": [
                "animal",
                "insect",
                "nature",
                "ladybug"
              ],
              "emoji": "🐞"
            },
            {
              "keywords": [
                "animal",
                "insect",
                "nature",
                "bug"
              ],
              "emoji": "🐜"
            },
             {
              "keywords": [
                "animal",
                "cricket",
                "chirp"
              ],
              "emoji": "🦗"
            },
            {
              "keywords": [
                "animal",
                "arachnid"
              ],
              "emoji": "🕷"
            },
            {
              "keywords": [
                "animal",
                "arachnid"
              ],
              "emoji": "🦂"
            },
            {
              "keywords": [
                "animal",
                "crustacean"
              ],
              "emoji": "🦀"
            },
            {
              "keywords": [
                "animal",
                "evil",
                "nature",
                "hiss",
                "python"
              ],
              "emoji": "🐍"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "reptile"
              ],
              "emoji": "🦎"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "dinosaur",
                "tyrannosaurus",
                "extinct"
              ],
              "emoji": "🦖"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "dinosaur",
                "brachiosaurus",
                "brontosaurus",
                "diplodocus",
                "extinct"
              ],
              "emoji": "🦕"
            },
            {
              "keywords": [
                "animal",
                "slow",
                "nature",
                "tortoise"
              ],
              "emoji": "🐢"
            },
            {
              "keywords": [
                "animal",
                "swim",
                "ocean",
                "beach",
                "nemo"
              ],
              "emoji": "🐠"
            },
            {
              "keywords": [
                "animal",
                "food",
                "nature"
              ],
              "emoji": "🐟"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "food",
                "sea",
                "ocean"
              ],
              "emoji": "🐡"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "fish",
                "sea",
                "ocean",
                "flipper",
                "fins",
                "beach"
              ],
              "emoji": "🐬"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "fish",
                "sea",
                "ocean",
                "jaws",
                "fins",
                "beach"
              ],
              "emoji": "🦈"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "sea",
                "ocean"
              ],
              "emoji": "🐳"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "sea",
                "ocean"
              ],
              "emoji": "🐋"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "reptile",
                "lizard",
                "alligator"
              ],
              "emoji": "🐊"
            },
             {
              "keywords": [
                "animal",
                "nature"
              ],
              "emoji": "🐆"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "stripes",
                "safari"
              ],
              "emoji": "🦓"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "roar"
              ],
              "emoji": "🐅"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "ox",
                "cow"
              ],
              "emoji": "🐃"
            },
            {
              "keywords": [
                "animal",
                "cow",
                "beef"
              ],
              "emoji": "🐂"
            },
            {
              "keywords": [
                "beef",
                "ox",
                "animal",
                "nature",
                "moo",
                "milk"
              ],
              "emoji": "🐄"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "horns",
                "venison"
              ],
              "emoji": "🦌"
            },
            {
              "keywords": [
                "animal",
                "hot",
                "desert",
                "hump"
              ],
              "emoji": "🐪"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "hot",
                "desert",
                "hump"
              ],
              "emoji": "🐫"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "spots",
                "safari"
              ],
              "emoji": "🦒"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "nose",
                "th",
                "circus"
              ],
              "emoji": "🐘"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "horn"
              ],
              "emoji": "🦏"
            },
            {
              "keywords": [
                "animal",
                "nature"
              ],
              "emoji": "🐐"
            },
            {
              "keywords": [
                "animal",
                "sheep",
                "nature"
              ],
              "emoji": "🐏"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "wool",
                "shipit"
              ],
              "emoji": "🐑"
            },
            {
              "keywords": [
                "animal",
                "gamble",
                "luck"
              ],
              "emoji": "🐎"
            },
            {
              "keywords": [
                "animal",
                "nature"
              ],
              "emoji": "🐖"
            },
            {
              "keywords": [
                "animal",
                "mouse",
                "rodent"
              ],
              "emoji": "🐀"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "rodent"
              ],
              "emoji": "🐁"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "chicken"
              ],
              "emoji": "🐓"
            },
             {
              "keywords": [
                "animal",
                "bird"
              ],
              "emoji": "🦃"
            },
            {
              "keywords": [
                "animal",
                "bird"
              ],
              "emoji": "🕊"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "friend",
                "doge",
                "pet",
                "faithful"
              ],
              "emoji": "🐕"
            },
             {
              "keywords": [
                "dog",
                "animal",
                "101",
                "nature",
                "pet"
              ],
              "emoji": "🐩"
            },
            {
              "keywords": [
                "animal",
                "meow",
                "pet",
                "cats"
              ],
              "emoji": "🐈"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "pet",
                "magic",
                "spring"
              ],
              "emoji": "🐇"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "rodent",
                "squirrel"
              ],
              "emoji": "🐿"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "spiny"
              ],
              "emoji": "🦔"
            },
             {
              "keywords": [
                "animal",
                "nature"
              ],
              "emoji": "🦝"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "alpaca"
              ],
              "emoji": "🦙"
            },
            {
              "keywords": [
                "animal",
                "nature"
              ],
              "emoji": "🦛"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "australia",
                "joey",
                "hop",
                "marsupial"
              ],
              "emoji": "🦘"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "honey"
              ],
              "emoji": "🦡"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "bird"
              ],
              "emoji": "🦢"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "peahen",
                "bird"
              ],
              "emoji": "🦚"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "bird",
                "pirate",
                "talk"
              ],
              "emoji": "🦜"
            },
             {
              "keywords": [
                "animal",
                "nature",
                "bisque",
                "claws",
                "seafood"
              ],
              "emoji": "🦞"
            },
            {
              "keywords": [
                "animal",
                "nature",
                "insect",
                "malaria"
              ],
              "emoji": "🦟"
            },
            {
              "keywords": [
                "animal",
                "tracking",
                "footprints",
                "dog",
                "cat",
                "pet",
                "feet"
              ],
              "emoji": "🐾"
            },
            {
              "keywords": [
                "animal",
                "myth",
                "nature",
                "chinese",
                "green"
              ],
              "emoji": "🐉"
            },
            {
              "keywords": [
                "animal",
                "myth",
                "nature",
                "chinese",
                "green"
              ],
              "emoji": "🐲"
            },
             {
              "keywords": [
                "vegetable",
                "plant",
                "nature"
              ],
              "emoji": "🌵"
            },
             {
              "keywords": [
                "festival",
                "vacation",
                "december",
                "xmas",
                "celebration"
              ],
              "emoji": "🎄"
            },
            {
              "keywords": [
                "plant",
                "nature"
              ],
              "emoji": "🌲"
            },
            {
              "keywords": [
                "plant",
                "nature"
              ],
              "emoji": "🌳"
            },
            {
              "keywords": [
                "plant",
                "vegetable",
                "nature",
                "summer",
                "beach",
                "mojito",
                "tropical"
              ],
              "emoji": "🌴"
            },
             {
              "keywords": [
                "plant",
                "nature",
                "grass",
                "lawn",
                "spring"
              ],
              "emoji": "🌱"
            },
            {
              "keywords": [
                "vegetable",
                "plant",
                "medicine",
                "weed",
                "grass",
                "lawn"
              ],
              "emoji": "🌿"
            },
            {
              "keywords": [
                "vegetable",
                "plant",
                "nature",
                "irish",
                "clover"
              ],
              "emoji": "☘"
            },
            {
              "keywords": [
                "vegetable",
                "plant",
                "nature",
                "lucky",
                "irish"
              ],
              "emoji": "🍀"
            },
             {
              "keywords": [
                "plant",
                "nature",
                "vegetable",
                "panda",
                "pine_decoration"
              ],
              "emoji": "🎍"
            },
            {
              "keywords": [
                "plant",
                "nature",
                "branch",
                "summer"
              ],
              "emoji": "🎋"
            },
             {
              "keywords": [
                "nature",
                "plant",
                "tree",
                "vegetable",
                "grass",
                "lawn",
                "spring"
              ],
              "emoji": "🍃"
            },
             {
              "keywords": [
                "nature",
                "plant",
                "vegetable",
                "leaves"
              ],
              "emoji": "🍂"
            },
            {
              "keywords": [
                "nature",
                "plant",
                "vegetable",
                "ca",
                "fall"
              ],
              "emoji": "🍁"
            },
            {
              "keywords": [
                "nature",
                "plant"
              ],
              "emoji": "🌾"
            },
            {
              "keywords": [
                "plant",
                "vegetable",
                "flowers",
                "beach"
              ],
              "emoji": "🌺"
            },
            {
              "keywords": [
                "nature",
                "plant",
                "fall"
              ],
              "emoji": "🌻"
            },
            {
              "keywords": [
                "flowers",
                "valentines",
                "love",
                "spring"
              ],
              "emoji": "🌹"
            },
             {
              "keywords": [
                "plant",
                "nature",
                "flower"
              ],
              "emoji": "🥀"
            },
            {
              "keywords": [
                "flowers",
                "plant",
                "nature",
                "summer",
                "spring"
              ],
              "emoji": "🌷"
            },
            {
              "keywords": [
                "nature",
                "flowers",
                "yellow"
              ],
              "emoji": "🌼"
            },
             {
              "keywords": [
                "nature",
                "plant",
                "spring",
                "flower"
              ],
              "emoji": "🌸"
            },
            {
              "keywords": [
                "flowers",
                "nature",
                "spring"
              ],
              "emoji": "💐"
            },
             {
              "keywords": [
                "plant",
                "vegetable"
              ],
              "emoji": "🍄"
            },
            {
              "keywords": [
                "food",
                "squirrel"
              ],
              "emoji": "🌰"
            },
            {
              "keywords": [
                "halloween",
                "light",
                "pumpkin",
                "creepy",
                "fall"
              ],
              "emoji": "🎃"
            },
            {
              "keywords": [
                "nature",
                "sea",
                "beach"
              ],
              "emoji": "🐚"
            },
             {
              "keywords": [
                "animal",
                "insect",
                "arachnid",
                "silk"
              ],
              "emoji": "🕸"
            },
             {
              "keywords": [
                "globe",
                "world",
                "USA",
                "international"
              ],
              "emoji": "🌎"
            },
            {
              "keywords": [
                "globe",
                "world",
                "international"
              ],
              "emoji": "🌍"
            },
            {
              "keywords": [
                "globe",
                "world",
                "east",
                "international"
              ],
              "emoji": "🌏"
            },
            {
              "keywords": [
                "nature",
                "yellow",
                "twilight",
                "planet",
                "space",
                "night",
                "evening",
                "sleep"
              ],
              "emoji": "🌕"
            },
             {
              "keywords": [
                "nature",
                "twilight",
                "planet",
                "space",
                "night",
                "evening",
                "sleep",
                "waxing_gibbous_moon"
              ],
              "emoji": "🌖"
            },
             {
              "keywords": [
                "nature",
                "twilight",
                "planet",
                "space",
                "night",
                "evening",
                "sleep"
              ],
              "emoji": "🌗"
            },
            {
              "keywords": [
                "nature",
                "twilight",
                "planet",
                "space",
                "night",
                "evening",
                "sleep"
              ],
              "emoji": "🌘"
            },
             {
              "keywords": [
                "nature",
                "twilight",
                "planet",
                "space",
                "night",
                "evening",
                "sleep"
              ],
              "emoji": "🌑"
            },
             {
              "keywords": [
                "nature",
                "twilight",
                "planet",
                "space",
                "night",
                "evening",
                "sleep"
              ],
              "emoji": "🌒"
            },
            {
              "keywords": [
                "nature",
                "twilight",
                "planet",
                "space",
                "night",
                "evening",
                "sleep"
              ],
              "emoji": "🌓"
            },
             {
              "keywords": [
                "nature",
                "night",
                "sky",
                "gray",
                "twilight",
                "planet",
                "space",
                "evening",
                "sleep"
              ],
              "emoji": "🌔"
            },
             {
              "keywords": [
                "nature",
                "twilight",
                "planet",
                "space",
                "night",
                "evening",
                "sleep"
              ],
              "emoji": "🌚"
            },
             {
              "keywords": [
                "nature",
                "twilight",
                "planet",
                "space",
                "night",
                "evening",
                "sleep"
              ],
              "emoji": "🌝"
            },
            {
              "keywords": [
                "nature",
                "twilight",
                "planet",
                "space",
                "night",
                "evening",
                "sleep"
              ],
              "emoji": "🌛"
            },
             {
              "keywords": [
                "nature",
                "twilight",
                "planet",
                "space",
                "night",
                "evening",
                "sleep"
              ],
              "emoji": "🌜"
            },
            {
              "keywords": [
                "nature",
                "morning",
                "sky"
              ],
              "emoji": "🌞"
            },
            {
              "keywords": [
                "night",
                "sleep",
                "sky",
                "evening",
                "magic"
              ],
              "emoji": "🌙"
            },
            {
              "keywords": [
                "night",
                "yellow"
              ],
              "emoji": "⭐"
            },
            {
              "keywords": [
                "night",
                "sparkle",
                "awesome",
                "good",
                "magic"
              ],
              "emoji": "🌟"
            },
            {
              "keywords": [
                "star",
                "sparkle",
                "shoot",
                "magic"
              ],
              "emoji": "💫"
            },
            {
              "keywords": [
                "stars",
                "shine",
                "shiny",
                "cool",
                "awesome",
                "good",
                "magic"
              ],
              "emoji": "✨"
            },
            {
              "keywords": [
                "space"
              ],
              "emoji": "☄"
            },
            {
              "keywords": [
                "weather",
                "nature",
                "brightness",
                "summer",
                "beach",
                "spring"
              ],
              "emoji": "☀️"
            },
             {
              "keywords": [
                "weather"
              ],
              "emoji": "🌤"
            },
            {
              "keywords": [
                "weather",
                "nature",
                "cloudy",
                "morning",
                "fall",
                "spring"
              ],
              "emoji": "⛅"
            },
             {
              "keywords": [
                "weather"
              ],
              "emoji": "🌥"
            },
             {
              "keywords": [
                "weather"
              ],
              "emoji": "🌦"
            },
            {
              "keywords": [
                "weather",
                "sky"
              ],
              "emoji": "☁️"
            },
             {
              "keywords": [
                "weather"
              ],
              "emoji": "🌧"
            },
             {
              "keywords": [
                "weather",
                "lightning"
              ],
              "emoji": "⛈"
            },
             {
              "keywords": [
                "weather",
                "thunder"
              ],
              "emoji": "🌩"
            },
             {
              "keywords": [
                "thunder",
                "weather",
                "lightning bolt",
                "fast"
              ],
              "emoji": "⚡"
            },
             {
              "keywords": [
                "hot",
                "cook",
                "flame"
              ],
              "emoji": "🔥"
            },
             {
              "keywords": [
                "bomb",
                "explode",
                "explosion",
                "collision",
                "blown"
              ],
              "emoji": "💥"
            },
             {
              "keywords": [
                "winter",
                "season",
                "cold",
                "weather",
                "christmas",
                "xmas"
              ],
              "emoji": "❄️"
            },
            {
              "keywords": [
                "weather"
              ],
              "emoji": "🌨"
            },
             {
              "keywords": [
                "winter",
                "season",
                "cold",
                "weather",
                "christmas",
                "xmas",
                "frozen",
                "without_snow"
              ],
              "emoji": "⛄"
            },
             {
              "keywords": [
                "winter",
                "season",
                "cold",
                "weather",
                "christmas",
                "xmas",
                "frozen"
              ],
              "emoji": "☃"
            },
             {
              "keywords": [
                "gust",
                "air"
              ],
              "emoji": "🌬"
            },
            {
              "keywords": [
                "wind",
                "air",
                "fast",
                "shoo",
                "fart",
                "smoke",
                "puff"
              ],
              "emoji": "💨"
            },
             {
              "keywords": [
                "weather",
                "cyclone",
                "twister"
              ],
              "emoji": "🌪"
            },
            {
              "keywords": [
                "weather"
              ],
              "emoji": "🌫"
            },
             {
              "keywords": [
                "weather",
                "spring"
              ],
              "emoji": "☂"
            },
            {
              "keywords": [
                "rainy",
                "weather",
                "spring"
              ],
              "emoji": "☔"
            },
            {
              "keywords": [
                "water",
                "drip",
                "faucet",
                "spring"
              ],
              "emoji": "💧"
            },
             {
              "keywords": [
                "water",
                "drip",
                "oops"
              ],
              "emoji": "💦"
            },
            {
              "keywords": [
                "sea",
                "water",
                "wave",
                "nature",
                "tsunami",
                "disaster"
              ],
              "emoji": "🌊"
            }
          ]
      },
      {
          "id": "food_and_drink",
          "name": "Food",
          "symbol": "messages-emoji-keyboard-food.png",
          "emojis": [
            {
              "keywords": [
                "fruit",
                "nature"
              ],
              "emoji": "🍏"
            },
            {
              "keywords": [
                "fruit",
                "mac",
                "school"
              ],
              "emoji": "🍎"
            },
            {
              "keywords": [
                "fruit",
                "nature",
                "food"
              ],
              "emoji": "🍐"
            },
            {
              "keywords": [
                "food",
                "fruit",
                "nature",
                "orange"
              ],
              "emoji": "🍊"
            },
             {
              "keywords": [
                "fruit",
                "nature"
              ],
              "emoji": "🍋"
            },
            {
              "keywords": [
                "fruit",
                "food",
                "monkey"
              ],
              "emoji": "🍌"
            },
             {
              "keywords": [
                "fruit",
                "food",
                "picnic",
                "summer"
              ],
              "emoji": "🍉"
            },
            {
              "keywords": [
                "fruit",
                "food",
                "wine"
              ],
              "emoji": "🍇"
            },
            {
              "keywords": [
                "fruit",
                "food",
                "nature"
              ],
              "emoji": "🍓"
            },
             {
              "keywords": [
                "fruit",
                "nature",
                "food"
              ],
              "emoji": "🍈"
            },
             {
              "keywords": [
                "food",
                "fruit"
              ],
              "emoji": "🍒"
            },
             {
              "keywords": [
                "fruit",
                "nature",
                "food"
              ],
              "emoji": "🍑"
            },
            {
              "keywords": [
                "fruit",
                "nature",
                "food"
              ],
              "emoji": "🍍"
            },
             {
              "keywords": [
                "fruit",
                "nature",
                "food",
                "palm"
              ],
              "emoji": "🥥"
            },
             {
              "keywords": [
                "fruit",
                "food"
              ],
              "emoji": "🥝"
            },
            {
              "keywords": [
                "fruit",
                "food",
                "tropical"
              ],
              "emoji": "🥭"
            },
             {
              "keywords": [
                "fruit",
                "food"
              ],
              "emoji": "🥑"
            },
            {
              "keywords": [
                "fruit",
                "food",
                "vegetable"
              ],
              "emoji": "🥦"
            },
            {
              "keywords": [
                "fruit",
                "vegetable",
                "nature",
                "food"
              ],
              "emoji": "🍅"
            },
             {
              "keywords": [
                "vegetable",
                "nature",
                "food",
                "aubergine"
              ],
              "emoji": "🍆"
            },
             {
              "keywords": [
                "fruit",
                "food",
                "pickle"
              ],
              "emoji": "🥒"
            },
            {
              "keywords": [
                "vegetable",
                "food",
                "orange"
              ],
              "emoji": "🥕"
            },
             {
              "keywords": [
                "food",
                "spicy",
                "chilli",
                "chili"
              ],
              "emoji": "🌶"
            },
            {
              "keywords": [
                "food",
                "tuber",
                "vegatable",
                "starch"
              ],
              "emoji": "🥔"
            },
             {
              "keywords": [
                "food",
                "vegetable",
                "plant"
              ],
              "emoji": "🌽"
            },
             {
              "keywords": [
                "food",
                "vegetable",
                "plant",
                "bok choy",
                "cabbage",
                "kale",
                "lettuce"
              ],
              "emoji": "🥬"
            },
             {
              "keywords": [
                "food",
                "nature"
              ],
              "emoji": "🍠"
            },
             {
              "keywords": [
                "food",
                "nut"
              ],
              "emoji": "🥜"
            },
             {
              "keywords": [
                "bees",
                "sweet",
                "kitchen"
              ],
              "emoji": "🍯"
            },
             {
              "keywords": [
                "food",
                "bread",
                "french"
              ],
              "emoji": "🥐"
            },
             {
              "keywords": [
                "food",
                "wheat",
                "breakfast",
                "toast"
              ],
              "emoji": "🍞"
            },
             {
              "keywords": [
                "food",
                "bread",
                "french"
              ],
              "emoji": "🥖"
            },
            {
              "keywords": [
                "food",
                "bread",
                "bakery",
                "schmear"
              ],
              "emoji": "🥯"
            },
             {
              "keywords": [
                "food",
                "bread",
                "twisted"
              ],
              "emoji": "🥨"
            },
            {
              "keywords": [
                "food",
                "chadder"
              ],
              "emoji": "🧀"
            },
            {
              "keywords": [
                "food",
                "chicken",
                "breakfast"
              ],
              "emoji": "🥚"
            },
             {
              "keywords": [
                "food",
                "breakfast",
                "pork",
                "pig",
                "meat"
              ],
              "emoji": "🥓"
            },
            {
              "keywords": [
                "food",
                "cow",
                "meat",
                "cut",
                "chop",
                "lambchop",
                "porkchop"
              ],
              "emoji": "🥩"
            },
            {
              "keywords": [
                "food",
                "breakfast",
                "flapjacks",
                "hotcakes"
              ],
              "emoji": "🥞"
            },
            {
              "keywords": [
                "food",
                "meat",
                "drumstick",
                "bird",
                "chicken",
                "turkey"
              ],
              "emoji": "🍗"
            },
            {
              "keywords": [
                "good",
                "food",
                "drumstick"
              ],
              "emoji": "🍖"
            },
             {
              "keywords": [
                "skeleton"
              ],
              "emoji": "🦴"
            },
            {
              "keywords": [
                "food",
                "animal",
                "appetizer",
                "summer"
              ],
              "emoji": "🍤"
            },
            {
              "keywords": [
                "food",
                "breakfast",
                "kitchen",
                "egg"
              ],
              "emoji": "🍳"
            },
             {
              "keywords": [
                "meat",
                "fast food",
                "beef",
                "cheeseburger",
                "mcdonalds",
                "burger king"
              ],
              "emoji": "🍔"
            },
            {
              "keywords": [
                "chips",
                "snack",
                "fast food"
              ],
              "emoji": "🍟"
            },
            {
              "keywords": [
                "food",
                "flatbread",
                "stuffed",
                "gyro"
              ],
              "emoji": "🥙"
            },
            {
              "keywords": [
                "food",
                "frankfurter"
              ],
              "emoji": "🌭"
            },
             {
              "keywords": [
                "food",
                "party"
              ],
              "emoji": "🍕"
            },
             {
              "keywords": [
                "food",
                "lunch",
                "bread"
              ],
              "emoji": "🥪"
            },
             {
              "keywords": [
                "food",
                "soup"
              ],
              "emoji": "🥫"
            },
            {
              "keywords": [
                "food",
                "italian",
                "noodle"
              ],
              "emoji": "🍝"
            },
            {
              "keywords": [
                "food",
                "mexican"
              ],
              "emoji": "🌮"
            },
             {
              "keywords": [
                "food",
                "mexican"
              ],
              "emoji": "🌯"
            },
            {
              "keywords": [
                "food",
                "healthy",
                "lettuce"
              ],
              "emoji": "🥗"
            },
            {
              "keywords": [
                "food",
                "cooking",
                "casserole",
                "paella"
              ],
              "emoji": "🥘"
            },
            {
              "keywords": [
                "food",
                "japanese",
                "noodle",
                "chopsticks"
              ],
              "emoji": "🍜"
            },
            {
              "keywords": [
                "food",
                "meat",
                "soup"
              ],
              "emoji": "🍲"
            },
            {
              "keywords": [
                "food",
                "japan",
                "sea",
                "beach",
                "narutomaki",
                "pink",
                "swirl",
                "kamaboko",
                "surimi",
                "ramen"
              ],
              "emoji": "🍥"
            },
            {
              "keywords": [
                "food",
                "prophecy"
              ],
              "emoji": "🥠"
            },
            {
              "keywords": [
                "food",
                "fish",
                "japanese",
                "rice"
              ],
              "emoji": "🍣"
            },
            {
              "keywords": [
                "food",
                "japanese",
                "box"
              ],
              "emoji": "🍱"
            },
             {
              "keywords": [
                "food",
                "spicy",
                "hot",
                "indian"
              ],
              "emoji": "🍛"
            },
            {
              "keywords": [
                "food",
                "japanese"
              ],
              "emoji": "🍙"
            },
             {
              "keywords": [
                "food",
                "china",
                "asian"
              ],
              "emoji": "🍚"
            },
            {
              "keywords": [
                "food",
                "japanese"
              ],
              "emoji": "🍘"
            },
            {
              "keywords": [
                "food",
                "japanese"
              ],
              "emoji": "🍢"
            },
            {
              "keywords": [
                "food",
                "dessert",
                "sweet",
                "japanese",
                "barbecue",
                "meat"
              ],
              "emoji": "🍡"
            },
             {
              "keywords": [
                "hot",
                "dessert",
                "summer"
              ],
              "emoji": "🍧"
            },
            {
              "keywords": [
                "food",
                "hot",
                "dessert"
              ],
              "emoji": "🍨"
            },
            {
              "keywords": [
                "food",
                "hot",
                "dessert",
                "summer"
              ],
              "emoji": "🍦"
            },
            {
              "keywords": [
                "food",
                "dessert",
                "pastry"
              ],
              "emoji": "🥧"
            },
            {
              "keywords": [
                "food",
                "dessert"
              ],
              "emoji": "🍰"
            },
             {
              "keywords": [
                "food",
                "dessert",
                "bakery",
                "sweet"
              ],
              "emoji": "🧁"
            },
             {
              "keywords": [
                "food",
                "autumn"
              ],
              "emoji": "🥮"
            },
            {
              "keywords": [
                "food",
                "dessert",
                "cake"
              ],
              "emoji": "🎂"
            },
             {
              "keywords": [
                "dessert",
                "food"
              ],
              "emoji": "🍮"
            },
            {
              "keywords": [
                "snack",
                "dessert",
                "sweet",
                "lolly"
              ],
              "emoji": "🍬"
            },
             {
              "keywords": [
                "food",
                "snack",
                "candy",
                "sweet"
              ],
              "emoji": "🍭"
            },
            {
              "keywords": [
                "food",
                "snack",
                "dessert",
                "sweet"
              ],
              "emoji": "🍫"
            },
            {
              "keywords": [
                "food",
                "movie theater",
                "films",
                "snack"
              ],
              "emoji": "🍿"
            },
             {
              "keywords": [
                "food",
                "empanada",
                "pierogi",
                "potsticker"
              ],
              "emoji": "🥟"
            },
            {
              "keywords": [
                "food",
                "dessert",
                "snack",
                "sweet",
                "donut"
              ],
              "emoji": "🍩"
            },
            {
              "keywords": [
                "food",
                "snack",
                "oreo",
                "chocolate",
                "sweet",
                "dessert"
              ],
              "emoji": "🍪"
            },
             {
              "keywords": [
                "beverage",
                "drink",
                "cow"
              ],
              "emoji": "🥛"
            },
            {
              "keywords": [
                "relax",
                "beverage",
                "drink",
                "drunk",
                "party",
                "pub",
                "summer",
                "alcohol",
                "booze"
              ],
              "emoji": "🍺"
            },
             {
              "keywords": [
                "relax",
                "beverage",
                "drink",
                "drunk",
                "party",
                "pub",
                "summer",
                "alcohol",
                "booze"
              ],
              "emoji": "🍻"
            },
             {
              "keywords": [
                "beverage",
                "drink",
                "party",
                "alcohol",
                "celebrate",
                "cheers",
                "wine",
                "champagne",
                "toast"
              ],
              "emoji": "🥂"
            },
             {
              "keywords": [
                "drink",
                "beverage",
                "drunk",
                "alcohol",
                "booze"
              ],
              "emoji": "🍷"
            },
            {
              "keywords": [
                "drink",
                "beverage",
                "drunk",
                "alcohol",
                "liquor",
                "booze",
                "bourbon",
                "scotch",
                "whisky",
                "glass",
                "shot"
              ],
              "emoji": "🥃"
            },
            {
              "keywords": [
                "drink",
                "drunk",
                "alcohol",
                "beverage",
                "booze",
                "mojito"
              ],
              "emoji": "🍸"
            },
            {
              "keywords": [
                "beverage",
                "cocktail",
                "summer",
                "beach",
                "alcohol",
                "booze",
                "mojito"
              ],
              "emoji": "🍹"
            },
            {
              "keywords": [
                "drink",
                "wine",
                "bottle",
                "celebration"
              ],
              "emoji": "🍾"
            },
            {
              "keywords": [
                "wine",
                "drink",
                "drunk",
                "beverage",
                "japanese",
                "alcohol",
                "booze"
              ],
              "emoji": "🍶"
            },
             {
              "keywords": [
                "drink",
                "bowl",
                "breakfast",
                "green",
                "british"
              ],
              "emoji": "🍵"
            },
            {
              "keywords": [
                "drink",
                "soda"
              ],
              "emoji": "🥤"
            },
            {
              "keywords": [
                "beverage",
                "caffeine",
                "latte",
                "espresso"
              ],
              "emoji": "☕"
            },
             {
              "keywords": [
                "food",
                "container",
                "milk"
              ],
              "emoji": "🍼"
            },
            {
              "keywords": [
                "condiment",
                "shaker"
              ],
              "emoji": "🧂"
            },
            {
              "keywords": [
                "cutlery",
                "kitchen",
                "tableware"
              ],
              "emoji": "🥄"
            },
            {
              "keywords": [
                "cutlery",
                "kitchen"
              ],
              "emoji": "🍴"
            },
            {
              "keywords": [
                "food",
                "eat",
                "meal",
                "lunch",
                "dinner",
                "restaurant"
              ],
              "emoji": "🍽"
            },
            {
              "keywords": [
                "food",
                "breakfast",
                "cereal",
                "oatmeal",
                "porridge"
              ],
              "emoji": "🥣"
            },
            {
              "keywords": [
                "food",
                "leftovers"
              ],
              "emoji": "🥡"
            },
            {
              "keywords": [
                "food"
              ],
              "emoji": "🥢"
            }
          ]
      },
    
          {
              "id": "activity",
              "name": "Activity",
              "symbol": "messages-emoji-keyboard-activity.png",
              "emojis": [
                {
                  "keywords": [
                    "sports",
                    "football"
                  ],
                  "emoji": "⚽"
                },
                {
                  "keywords": [
                    "sports",
                    "balls",
                    "NBA"
                  ],
                  "emoji": "🏀"
                },
                 {
                  "keywords": [
                    "sports",
                    "balls",
                    "NFL"
                  ],
                  "emoji": "🏈"
                },
                 {
                  "keywords": [
                    "sports",
                    "balls"
                  ],
                  "emoji": "⚾"
                },
                {
                  "keywords": [
                    "sports",
                    "balls"
                  ],
                  "emoji": "🥎"
                },
                {
                  "keywords": [
                    "sports",
                    "balls",
                    "green"
                  ],
                  "emoji": "🎾"
                },
                {
                  "keywords": [
                    "sports",
                    "balls"
                  ],
                  "emoji": "🏐"
                },
                {
                  "keywords": [
                    "sports",
                    "team"
                  ],
                  "emoji": "🏉"
                },
                {
                  "keywords": [
                    "sports",
                    "frisbee",
                    "ultimate"
                  ],
                  "emoji": "🥏"
                },
                {
                  "keywords": [
                    "pool",
                    "hobby",
                    "game",
                    "luck",
                    "magic"
                  ],
                  "emoji": "🎱"
                },
                {
                  "keywords": [
                    "sports",
                    "business",
                    "flag",
                    "hole",
                    "summer"
                  ],
                  "emoji": "⛳"
                },
                {
                  "keywords": [
                    "sports",
                    "business",
                    "woman",
                    "female"
                  ],
                  "emoji": "🏌️‍♀️"
                },
                 {
                  "keywords": [
                    "sports",
                    "business"
                  ],
                  "emoji": "🏌",
                  "fitzpatrick_scale": true
                },
                {
                  "keywords": [
                    "sports",
                    "pingpong"
                  ],
                  "emoji": "🏓"
                },
                {
                  "keywords": [
                    "sports"
                  ],
                  "emoji": "🏸"
                },
                {
                  "keywords": [
                    "sports"
                  ],
                  "emoji": "🥅"
                },
                {
                  "keywords": [
                    "sports"
                  ],
                  "emoji": "🏒"
                },
                {
                  "keywords": [
                    "sports"
                  ],
                  "emoji": "🏑"
                },
                {
                  "keywords": [
                    "sports",
                    "ball",
                    "stick"
                  ],
                  "emoji": "🥍"
                },
                {
                  "keywords": [
                    "sports"
                  ],
                  "emoji": "🏏"
                },
                {
                  "keywords": [
                    "sports",
                    "winter",
                    "cold",
                    "snow"
                  ],
                  "emoji": "🎿"
                },
                 {
                  "keywords": [
                    "sports",
                    "winter",
                    "snow"
                  ],
                  "emoji": "⛷"
                },
                {
                  "keywords": [
                    "sports",
                    "winter"
                  ],
                  "emoji": "🏂"
                },
                {
                  "keywords": [
                    "sports",
                    "fencing",
                    "sword"
                  ],
                  "emoji": "🤺"
                },
                {
                  "keywords": [
                    "sports",
                    "wrestlers"
                  ],
                  "emoji": "🤼‍♀️"
                },
                {
                  "keywords": [
                    "sports",
                    "wrestlers"
                  ],
                  "emoji": "🤼‍♂️"
                },
                 {
                  "keywords": [
                    "gymnastics"
                  ],
                  "emoji": "🤸‍♀️"
                },
                {
                  "keywords": [
                    "gymnastics"
                  ],
                  "emoji": "🤸‍♂️"
                },
                {
                  "keywords": [
                    "sports"
                  ],
                  "emoji": "🤾‍♀️"
                },
                {
                  "keywords": [
                    "sports"
                  ],
                  "emoji": "🤾‍♂️"
                },
                {
                  "keywords": [
                    "sports"
                  ],
                  "emoji": "⛸"
                },
                {
                  "keywords": [
                    "sports"
                  ],
                  "emoji": "🥌"
                },
                {
                  "keywords": [
                    "board"
                  ],
                  "emoji": "🛹"
                },
                {
                  "keywords": [
                    "sleigh",
                    "luge",
                    "toboggan"
                  ],
                  "emoji": "🛷"
                },
                {
                  "keywords": [
                    "sports"
                  ],
                  "emoji": "🏹"
                },
                 {
                  "keywords": [
                    "food",
                    "hobby",
                    "summer"
                  ],
                  "emoji": "🎣"
                },
                {
                  "keywords": [
                    "sports",
                    "fighting"
                  ],
                  "emoji": "🥊"
                },
                {
                  "keywords": [
                    "judo",
                    "karate",
                    "taekwondo"
                  ],
                  "emoji": "🥋"
                },
                {
                  "keywords": [
                    "sports",
                    "hobby",
                    "water",
                    "ship",
                    "woman",
                    "female"
                  ],
                  "emoji": "🚣‍♀️"
                },
                {
                  "keywords": [
                    "sports",
                    "hobby",
                    "water",
                    "ship"
                  ],
                  "emoji": "🚣"
                },
                {
                  "keywords": [
                    "sports",
                    "hobby",
                    "woman",
                    "female",
                    "rock"
                  ],
                  "emoji": "🧗‍♀️"
                },
                {
                  "keywords": [
                    "sports",
                    "hobby",
                    "man",
                    "male",
                    "rock"
                  ],
                  "emoji": "🧗‍♂️"
                },
                {
                  "keywords": [
                    "sports",
                    "exercise",
                    "human",
                    "athlete",
                    "water",
                    "summer",
                    "woman",
                    "female"
                  ],
                  "emoji": "🏊‍♀️"
                },
                {
                  "keywords": [
                    "sports",
                    "exercise",
                    "human",
                    "athlete",
                    "water",
                    "summer"
                  ],
                  "emoji": "🏊"
                },
                {
                  "keywords": [
                    "sports",
                    "pool"
                  ],
                  "emoji": "🤽‍♀️"
                },
                {
                  "keywords": [
                    "sports",
                    "pool"
                  ],
                  "emoji": "🤽‍♂️"
                },
                {
                  "keywords": [
                    "woman",
                    "female",
                    "meditation",
                    "yoga",
                    "serenity",
                    "zen",
                    "mindfulness"
                  ],
                  "emoji": "🧘‍♀️"
                },
                {
                  "keywords": [
                    "man",
                    "male",
                    "meditation",
                    "yoga",
                    "serenity",
                    "zen",
                    "mindfulness"
                  ],
                  "emoji": "🧘‍♂️"
                },
                 {
                  "keywords": [
                    "sports",
                    "ocean",
                    "sea",
                    "summer",
                    "beach",
                    "woman",
                    "female"
                  ],
                  "emoji": "🏄‍♀️"
                },
                {
                  "keywords": [
                    "sports",
                    "ocean",
                    "sea",
                    "summer",
                    "beach"
                  ],
                  "emoji": "🏄"
                },
                {
                  "keywords": [
                    "clean",
                    "shower",
                    "bathroom"
                  ],
                  "emoji": "🛀"
                },
                {
                  "keywords": [
                    "sports",
                    "human",
                    "woman",
                    "female"
                  ],
                  "emoji": "⛹️‍♀️"
                },
                {
                  "keywords": [
                    "sports",
                    "human"
                  ],
                  "emoji": "⛹"
                },
                {
                  "keywords": [
                    "sports",
                    "training",
                    "exercise",
                    "woman",
                    "female"
                  ],
                  "emoji": "🏋️‍♀️"
                },
                {
                  "keywords": [
                    "sports",
                    "training",
                    "exercise"
                  ],
                  "emoji": "🏋"
                },
                 {
                  "keywords": [
                    "sports",
                    "bike",
                    "exercise",
                    "hipster",
                    "woman",
                    "female"
                  ],
                  "emoji": "🚴‍♀️"
                },
                 {
                  "keywords": [
                    "sports",
                    "bike",
                    "exercise",
                    "hipster"
                  ],
                  "emoji": "🚴"
                },
                {
                  "keywords": [
                    "transportation",
                    "sports",
                    "human",
                    "race",
                    "bike",
                    "woman",
                    "female"
                  ],
                  "emoji": "🚵‍♀️"
                },
                {
                  "keywords": [
                    "transportation",
                    "sports",
                    "human",
                    "race",
                    "bike"
                  ],
                  "emoji": "🚵"
                },
                {
                  "keywords": [
                    "animal",
                    "betting",
                    "competition",
                    "gambling",
                    "luck"
                  ],
                  "emoji": "🏇"
                },
                {
                  "keywords": [
                    "suit",
                    "business",
                    "levitate",
                    "hover",
                    "jump"
                  ],
                  "emoji": "🕴"
                },
                {
                  "keywords": [
                    "win",
                    "award",
                    "contest",
                    "place",
                    "ftw",
                    "ceremony"
                  ],
                  "emoji": "🏆"
                },
                {
                  "keywords": [
                    "play",
                    "pageant"
                  ],
                  "emoji": "🎽"
                },
                 {
                  "keywords": [
                    "award",
                    "winning"
                  ],
                  "emoji": "🏅"
                },
                {
                  "keywords": [
                    "award",
                    "winning",
                    "army"
                  ],
                  "emoji": "🎖"
                },
                {
                  "keywords": [
                    "award",
                    "winning",
                    "first"
                  ],
                  "emoji": "🥇"
                },
                {
                  "keywords": [
                    "award",
                    "second"
                  ],
                  "emoji": "🥈"
                },
                {
                  "keywords": [
                    "award",
                    "third"
                  ],
                  "emoji": "🥉"
                },
                {
                  "keywords": [
                    "sports",
                    "cause",
                    "support",
                    "awareness"
                  ],
                  "emoji": "🎗"
                },
                 {
                  "keywords": [
                    "flower",
                    "decoration",
                    "military"
                  ],
                  "emoji": "🏵"
                },
                {
                  "keywords": [
                    "event",
                    "concert",
                    "pass"
                  ],
                  "emoji": "🎫"
                },
                {
                  "keywords": [
                    "sports",
                    "concert",
                    "entrance"
                  ],
                  "emoji": "🎟"
                },
                {
                  "keywords": [
                    "acting",
                    "theater",
                    "drama"
                  ],
                  "emoji": "🎭"
                },
                {
                  "keywords": [
                    "design",
                    "paint",
                    "draw",
                    "colors"
                  ],
                  "emoji": "🎨"
                },
                {
                  "keywords": [
                    "festival",
                    "carnival",
                    "party"
                  ],
                  "emoji": "🎪"
                },
                {
                  "keywords": [
                    "juggle",
                    "balance",
                    "skill",
                    "multitask"
                  ],
                  "emoji": "🤹‍♀️"
                },
                {
                  "keywords": [
                    "juggle",
                    "balance",
                    "skill",
                    "multitask"
                  ],
                  "emoji": "🤹‍♂️"
                },
                {
                  "keywords": [
                    "sound",
                    "music",
                    "PA",
                    "sing",
                    "talkshow"
                  ],
                  "emoji": "🎤"
                },
                {
                  "keywords": [
                    "music",
                    "score",
                    "gadgets"
                  ],
                  "emoji": "🎧"
                },
                 {
                  "keywords": [
                    "treble",
                    "clef",
                    "compose"
                  ],
                  "emoji": "🎼"
                },
                {
                  "keywords": [
                    "piano",
                    "instrument",
                    "compose"
                  ],
                  "emoji": "🎹"
                },
                {
                  "keywords": [
                    "music",
                    "instrument",
                    "drumsticks",
                    "snare"
                  ],
                  "emoji": "🥁"
                },
                {
                  "keywords": [
                    "music",
                    "instrument",
                    "jazz",
                    "blues"
                  ],
                  "emoji": "🎷"
                },
                {
                  "keywords": [
                    "music",
                    "brass"
                  ],
                  "emoji": "🎺"
                },
                {
                  "keywords": [
                    "music",
                    "instrument"
                  ],
                  "emoji": "🎸"
                },
                {
                  "keywords": [
                    "music",
                    "instrument",
                    "orchestra",
                    "symphony"
                  ],
                  "emoji": "🎻"
                },
                {
                  "keywords": [
                    "movie",
                    "film",
                    "record"
                  ],
                  "emoji": "🎬"
                },
                {
                  "keywords": [
                    "play",
                    "console",
                    "PS4",
                    "controller"
                  ],
                  "emoji": "🎮"
                },
                 {
                  "keywords": [
                    "game",
                    "arcade",
                    "play"
                  ],
                  "emoji": "👾"
                },
                {
                  "keywords": [
                    "game",
                    "play",
                    "bar",
                    "target",
                    "bullseye"
                  ],
                  "emoji": "🎯"
                },
                {
                  "keywords": [
                    "dice",
                    "random",
                    "tabletop",
                    "play",
                    "luck"
                  ],
                  "emoji": "🎲"
                },
                 {
                  "keywords": [
                    "expendable"
                  ],
                  "emoji": "♟"
                },
                {
                  "keywords": [
                    "bet",
                    "gamble",
                    "vegas",
                    "fruit machine",
                    "luck",
                    "casino"
                  ],
                  "emoji": "🎰"
                },
                {
                  "keywords": [
                    "interlocking",
                    "puzzle",
                    "piece"
                  ],
                  "emoji": "🧩"
                },
                {
                  "keywords": [
                    "sports",
                    "fun",
                    "play"
                  ],
                  "emoji": "🎳"
                }
              ]
          },
      {
          "id": "travel_and_places",
          "name": "Travel & Places",
          "symbol": "messages-emoji-keyboard-travel.png",
          "emojis": [
             {
              "keywords": [
                "red",
                "transportation",
                "vehicle"
              ],
              "emoji": "🚗"
            },
            {
              "keywords": [
                "uber",
                "vehicle",
                "cars",
                "transportation"
              ],
              "emoji": "🚕"
            },
            {
              "keywords": [
                "transportation",
                "vehicle"
              ],
              "emoji": "🚙"
            },
            {
              "keywords": [
                "car",
                "vehicle",
                "transportation"
              ],
              "emoji": "🚌"
            },
            {
              "keywords": [
                "bart",
                "transportation",
                "vehicle"
              ],
              "emoji": "🚎"
            },
             {
              "keywords": [
                "sports",
                "race",
                "fast",
                "formula",
                "f1"
              ],
              "emoji": "🏎"
            },
             {
              "keywords": [
                "vehicle",
                "cars",
                "transportation",
                "law",
                "legal",
                "enforcement"
              ],
              "emoji": "🚓"
            },
             {
              "keywords": [
                "health",
                "911",
                "hospital"
              ],
              "emoji": "🚑"
            },
             {
              "keywords": [
                "transportation",
                "cars",
                "vehicle"
              ],
              "emoji": "🚒"
            },
            {
              "keywords": [
                "vehicle",
                "car",
                "transportation"
              ],
              "emoji": "🚐"
            },
             {
              "keywords": [
                "cars",
                "transportation"
              ],
              "emoji": "🚚"
            },
            {
              "keywords": [
                "vehicle",
                "cars",
                "transportation",
                "express"
              ],
              "emoji": "🚛"
            },
            {
              "keywords": [
                "vehicle",
                "car",
                "farming",
                "agriculture"
              ],
              "emoji": "🚜"
            },
            {
              "keywords": [
                "vehicle",
                "kick",
                "razor"
              ],
              "emoji": "🛴"
            },
            {
              "keywords": [
                "race",
                "sports",
                "fast"
              ],
              "emoji": "🏍"
            },
            {
              "keywords": [
                "sports",
                "bicycle",
                "exercise",
                "hipster"
              ],
              "emoji": "🚲"
            },
             {
              "keywords": [
                "vehicle",
                "vespa",
                "sasha"
              ],
              "emoji": "🛵"
            },
             {
              "keywords": [
                "police",
                "ambulance",
                "911",
                "emergency",
                "alert",
                "error",
                "pinged",
                "law",
                "legal"
              ],
              "emoji": "🚨"
            },
            {
              "keywords": [
                "vehicle",
                "law",
                "legal",
                "enforcement",
                "911"
              ],
              "emoji": "🚔"
            },
            {
              "keywords": [
                "vehicle",
                "transportation"
              ],
              "emoji": "🚍"
            },
            {
              "keywords": [
                "car",
                "vehicle",
                "transportation"
              ],
              "emoji": "🚘"
            },
            {
              "keywords": [
                "vehicle",
                "cars",
                "uber"
              ],
              "emoji": "🚖"
            },
            {
              "keywords": [
                "transportation",
                "vehicle",
                "ski"
              ],
              "emoji": "🚡"
            },
            {
              "keywords": [
                "transportation",
                "vehicle",
                "ski"
              ],
              "emoji": "🚠"
            },
            {
              "keywords": [
                "vehicle",
                "transportation"
              ],
              "emoji": "🚟"
            },
            {
              "keywords": [
                "transportation",
                "vehicle"
              ],
              "emoji": "🚃"
            },
            {
              "keywords": [
                "transportation",
                "vehicle",
                "carriage",
                "public",
                "travel"
              ],
              "emoji": "🚋"
            },
             {
              "keywords": [
                "transportation",
                "vehicle"
              ],
              "emoji": "🚝"
            },
            {
              "keywords": [
                "transportation",
                "vehicle"
              ],
              "emoji": "🚄"
            },
            {
              "keywords": [
                "transportation",
                "vehicle",
                "speed",
                "fast",
                "public",
                "travel"
              ],
              "emoji": "🚅"
            },
            {
              "keywords": [
                "transportation",
                "vehicle"
              ],
              "emoji": "🚈"
            },
             {
              "keywords": [
                "transportation",
                "vehicle"
              ],
              "emoji": "🚞"
            },
             {
              "keywords": [
                "transportation",
                "vehicle",
                "train"
              ],
              "emoji": "🚂"
            },
            {
              "keywords": [
                "transportation",
                "vehicle"
              ],
              "emoji": "🚆"
            },
             {
              "keywords": [
                "transportation",
                "blue-square",
                "mrt",
                "underground",
                "tube"
              ],
              "emoji": "🚇"
            },
            {
              "keywords": [
                "transportation",
                "vehicle"
              ],
              "emoji": "🚊"
            },
             {
              "keywords": [
                "transportation",
                "vehicle",
                "public"
              ],
              "emoji": "🚉"
            },
             {
              "keywords": [
                "transportation",
                "vehicle",
                "ufo"
              ],
              "emoji": "🛸"
            },
            {
              "keywords": [
                "transportation",
                "vehicle",
                "fly"
              ],
              "emoji": "🚁"
            },
             {
              "keywords": [
                "flight",
                "transportation",
                "fly",
                "vehicle"
              ],
              "emoji": "🛩"
            },
            {
              "keywords": [
                "vehicle",
                "transportation",
                "flight",
                "fly"
              ],
              "emoji": "✈️"
            },
             {
              "keywords": [
                "airport",
                "flight",
                "landing"
              ],
              "emoji": "🛫"
            },
            {
              "keywords": [
                "airport",
                "flight",
                "boarding"
              ],
              "emoji": "🛬"
            },
             {
              "keywords": [
                "ship",
                "summer",
                "transportation",
                "water",
                "sailing"
              ],
              "emoji": "⛵"
            },
             {
              "keywords": [
                "ship"
              ],
              "emoji": "🛥"
            },
            {
              "keywords": [
                "ship",
                "transportation",
                "vehicle",
                "summer"
              ],
              "emoji": "🚤"
            },
            {
              "keywords": [
                "boat",
                "ship",
                "yacht"
              ],
              "emoji": "⛴"
            },
            {
              "keywords": [
                "yacht",
                "cruise",
                "ferry"
              ],
              "emoji": "🛳"
            },
             {
              "keywords": [
                "launch",
                "ship",
                "staffmode",
                "NASA",
                "outer space",
                "outer_space",
                "fly"
              ],
              "emoji": "🚀"
            },
            {
              "keywords": [
                "communication",
                "gps",
                "orbit",
                "spaceflight",
                "NASA",
                "ISS"
              ],
              "emoji": "🛰"
            },
            {
              "keywords": [
                "sit",
                "airplane",
                "transport",
                "bus",
                "flight",
                "fly"
              ],
              "emoji": "💺"
            },
             {
              "keywords": [
                "boat",
                "paddle",
                "water",
                "ship"
              ],
              "emoji": "🛶"
            },
             {
              "keywords": [
                "ship",
                "ferry",
                "sea",
                "boat"
              ],
              "emoji": "⚓"
            },
            {
              "keywords": [
                "wip",
                "progress",
                "caution",
                "warning"
              ],
              "emoji": "🚧"
            },
            {
              "keywords": [
                "gas station",
                "petroleum"
              ],
              "emoji": "⛽"
            },
            {
              "keywords": [
                "transportation",
                "wait"
              ],
              "emoji": "🚏"
            },
            {
              "keywords": [
                "transportation",
                "driving"
              ],
              "emoji": "🚦"
            },
            {
              "keywords": [
                "transportation",
                "signal"
              ],
              "emoji": "🚥"
            },
             {
              "keywords": [
                "contest",
                "finishline",
                "race",
                "gokart"
              ],
              "emoji": "🏁"
            },
            {
              "keywords": [
                "transportation",
                "titanic",
                "deploy"
              ],
              "emoji": "🚢"
            },
             {
              "keywords": [
                "photo",
                "carnival",
                "londoneye"
              ],
              "emoji": "🎡"
            },
             {
              "keywords": [
                "carnival",
                "playground",
                "photo",
                "fun"
              ],
              "emoji": "🎢"
            },
            {
              "keywords": [
                "photo",
                "carnival"
              ],
              "emoji": "🎠"
            },
            {
              "keywords": [
                "wip",
                "working",
                "progress"
              ],
              "emoji": "🏗"
            },
            {
              "keywords": [
                "photo",
                "mountain"
              ],
              "emoji": "🌁"
            },
            {
              "keywords": [
                "photo",
                "japanese"
              ],
              "emoji": "🗼"
            },
            {
              "keywords": [
                "building",
                "industry",
                "pollution",
                "smoke"
              ],
              "emoji": "🏭"
            },
            {
              "keywords": [
                "photo",
                "summer",
                "water",
                "fresh"
              ],
              "emoji": "⛲"
            },
            {
              "keywords": [
                "photo",
                "japan",
                "asia",
                "tsukimi"
              ],
              "emoji": "🎑"
            },
            {
              "keywords": [
                "photo",
                "nature",
                "environment"
              ],
              "emoji": "⛰"
            },
             {
              "keywords": [
                "photo",
                "nature",
                "environment",
                "winter",
                "cold"
              ],
              "emoji": "🏔"
            },
             {
              "keywords": [
                "photo",
                "mountain",
                "nature",
                "japanese"
              ],
              "emoji": "🗻"
            },
             {
              "keywords": [
                "photo",
                "nature",
                "disaster"
              ],
              "emoji": "🌋"
            },
            {
              "keywords": [
                "nation",
                "country",
                "japanese",
                "asia"
              ],
              "emoji": "🗾"
            },
             {
              "keywords": [
                "photo",
                "outdoors",
                "tent"
              ],
              "emoji": "🏕"
            },
            {
              "keywords": [
                "photo",
                "camping",
                "outdoors"
              ],
              "emoji": "⛺"
            },
            {
              "keywords": [
                "photo",
                "environment",
                "nature"
              ],
              "emoji": "🏞"
            },
            {
              "keywords": [
                "road",
                "cupertino",
                "interstate",
                "highway"
              ],
              "emoji": "🛣"
            },
            {
              "keywords": [
                "train",
                "transportation"
              ],
              "emoji": "🛤"
            },
             {
              "keywords": [
                "morning",
                "view",
                "vacation",
                "photo"
              ],
              "emoji": "🌅"
            },
            {
              "keywords": [
                "view",
                "vacation",
                "photo"
              ],
              "emoji": "🌄"
            },
            {
              "keywords": [
                "photo",
                "warm",
                "saharah"
              ],
              "emoji": "🏜"
            },
             {
              "keywords": [
                "weather",
                "summer",
                "sunny",
                "sand",
                "mojito"
              ],
              "emoji": "🏖"
            },
            {
              "keywords": [
                "photo",
                "tropical",
                "mojito"
              ],
              "emoji": "🏝"
            },
            {
              "keywords": [
                "photo",
                "good morning",
                "dawn"
              ],
              "emoji": "🌇"
            },
             {
              "keywords": [
                "photo",
                "evening",
                "sky",
                "buildings"
              ],
              "emoji": "🌆"
            },
            {
              "keywords": [
                "photo",
                "night life",
                "urban"
              ],
              "emoji": "🏙"
            },
             {
              "keywords": [
                "evening",
                "city",
                "downtown"
              ],
              "emoji": "🌃"
            },
             {
              "keywords": [
                "photo",
                "sanfrancisco"
              ],
              "emoji": "🌉"
            },
             {
              "keywords": [
                "photo",
                "space",
                "stars"
              ],
              "emoji": "🌌"
            },
            {
              "keywords": [
                "night",
                "photo"
              ],
              "emoji": "🌠"
            },
             {
              "keywords": [
                "stars",
                "night",
                "shine"
              ],
              "emoji": "🎇"
            },
            {
              "keywords": [
                "photo",
                "festival",
                "carnival",
                "congratulations"
              ],
              "emoji": "🎆"
            },
            {
              "keywords": [
                "nature",
                "happy",
                "unicorn_face",
                "photo",
                "sky",
                "spring"
              ],
              "emoji": "🌈"
            },
             {
              "keywords": [
                "buildings",
                "photo"
              ],
              "emoji": "🏘"
            },
            {
              "keywords": [
                "building",
                "royalty",
                "history"
              ],
              "emoji": "🏰"
            },
            {
              "keywords": [
                "photo",
                "building"
              ],
              "emoji": "🏯"
            },
            {
              "keywords": [
                "photo",
                "place",
                "sports",
                "concert",
                "venue"
              ],
              "emoji": "🏟"
            },
             {
              "keywords": [
                "american",
                "newyork"
              ],
              "emoji": "🗽"
            },
            {
              "keywords": [
                "building",
                "home"
              ],
              "emoji": "🏠"
            },
            {
              "keywords": [
                "home",
                "plant",
                "nature"
              ],
              "emoji": "🏡"
            },
            {
              "keywords": [
                "abandon",
                "evict",
                "broken",
                "building"
              ],
              "emoji": "🏚"
            },
            {
              "keywords": [
                "building",
                "bureau",
                "work"
              ],
              "emoji": "🏢"
            },
             {
              "keywords": [
                "building",
                "shopping",
                "mall"
              ],
              "emoji": "🏬"
            },
            {
              "keywords": [
                "building",
                "envelope",
                "communication"
              ],
              "emoji": "🏣"
            },
             {
              "keywords": [
                "building",
                "email"
              ],
              "emoji": "🏤"
            },
            {
              "keywords": [
                "building",
                "health",
                "surgery",
                "doctor"
              ],
              "emoji": "🏥"
            },
            {
              "keywords": [
                "building",
                "money",
                "sales",
                "cash",
                "business",
                "enterprise"
              ],
              "emoji": "🏦"
            },
            {
              "keywords": [
                "building",
                "accomodation",
                "checkin"
              ],
              "emoji": "🏨"
            },
            {
              "keywords": [
                "building",
                "shopping",
                "groceries"
              ],
              "emoji": "🏪"
            },
            {
              "keywords": [
                "building",
                "student",
                "education",
                "learn",
                "teach"
              ],
              "emoji": "🏫"
            },
            {
              "keywords": [
                "like",
                "affection",
                "dating"
              ],
              "emoji": "🏩"
            },
            {
              "keywords": [
                "love",
                "like",
                "affection",
                "couple",
                "marriage",
                "bride",
                "groom"
              ],
              "emoji": "💒"
            },
            {
              "keywords": [
                "art",
                "culture",
                "history"
              ],
              "emoji": "🏛"
            },
            {
              "keywords": [
                "building",
                "religion",
                "christ"
              ],
              "emoji": "⛪"
            },
             {
              "keywords": [
                "islam",
                "worship",
                "minaret"
              ],
              "emoji": "🕌"
            },
            {
              "keywords": [
                "judaism",
                "worship",
                "temple",
                "jewish"
              ],
              "emoji": "🕍"
            },
            {
              "keywords": [
                "mecca",
                "mosque",
                "islam"
              ],
              "emoji": "🕋"
            },
             {
              "keywords": [
                "temple",
                "japan",
                "kyoto"
              ],
              "emoji": "⛩"
            }
          ]
      },
      {
          "id": "objects",
          "name": "Objects",
          "symbol": "messages-emoji-keyboard-objects.png",
          "emojis": [
             {
              "keywords": [
                "time",
                "accessories"
              ],
              "emoji": "⌚"
            },
             {
              "keywords": [
                "technology",
                "apple",
                "gadgets",
                "dial"
              ],
              "emoji": "📱"
            },
             {
              "keywords": [
                "iphone",
                "incoming"
              ],
              "emoji": "📲"
            },
            {
              "keywords": [
                "technology",
                "laptop",
                "screen",
                "display",
                "monitor"
              ],
              "emoji": "💻"
            },
             {
              "keywords": [
                "technology",
                "computer",
                "type",
                "input",
                "text"
              ],
              "emoji": "⌨"
            },
             {
              "keywords": [
                "technology",
                "computing",
                "screen"
              ],
              "emoji": "🖥"
            },
            {
              "keywords": [
                "paper",
                "ink"
              ],
              "emoji": "🖨"
            },
            {
              "keywords": [
                "click"
              ],
              "emoji": "🖱"
            },
             {
              "keywords": [
                "technology",
                "trackpad"
              ],
              "emoji": "🖲"
            },
            {
              "keywords": [
                "game",
                "play"
              ],
              "emoji": "🕹"
            },
            {
              "keywords": [
                "tool"
              ],
              "emoji": "🗜"
            },
             {
              "keywords": [
                "technology",
                "record",
                "emojis",
                "disk",
                "90s"
              ],
              "emoji": "💽"
            },
             {
              "keywords": [
                "oldschool",
                "technology",
                "save",
                "90s",
                "80s"
              ],
              "emoji": "💾"
            },
            {
              "keywords": [
                "technology",
                "dvd",
                "disk",
                "disc",
                "90s"
              ],
              "emoji": "💿"
            },
             {
              "keywords": [
                "cd",
                "disk",
                "disc"
              ],
              "emoji": "📀"
            },
             {
              "keywords": [
                "record",
                "video",
                "oldschool",
                "90s",
                "80s"
              ],
              "emoji": "📼"
            },
             {
              "keywords": [
                "gadgets",
                "photography"
              ],
              "emoji": "📷"
            },
             {
              "keywords": [
                "photography",
                "gadgets"
              ],
              "emoji": "📸"
            },
            {
              "keywords": [
                "film",
                "record"
              ],
              "emoji": "📹"
            },
            {
              "keywords": [
                "film",
                "record"
              ],
              "emoji": "🎥"
            },
            {
              "keywords": [
                "video",
                "tape",
                "record",
                "movie"
              ],
              "emoji": "📽"
            },
            {
              "keywords": [
                "movie"
              ],
              "emoji": "🎞"
            },
            {
              "keywords": [
                "technology",
                "communication",
                "dial"
              ],
              "emoji": "📞"
            },
            {
              "keywords": [
                "technology",
                "communication",
                "dial",
                "telephone"
              ],
              "emoji": "☎️"
            },
             {
              "keywords": [
                "bbcall",
                "oldschool",
                "90s"
              ],
              "emoji": "📟"
            },
            {
              "keywords": [
                "communication",
                "technology"
              ],
              "emoji": "📠"
            },
            {
              "keywords": [
                "technology",
                "program",
                "oldschool",
                "show",
                "television"
              ],
              "emoji": "📺"
            },
             {
              "keywords": [
                "communication",
                "music",
                "podcast",
                "program"
              ],
              "emoji": "📻"
            },
             {
              "keywords": [
                "sing",
                "recording",
                "artist",
                "talkshow"
              ],
              "emoji": "🎙"
            },
             {
              "keywords": [
                "scale"
              ],
              "emoji": "🎚"
            },
             {
              "keywords": [
                "dial"
              ],
              "emoji": "🎛"
            },
             {
              "keywords": [
                "magnetic",
                "navigation",
                "orienteering"
              ],
              "emoji": "🧭"
            },
            {
              "keywords": [
                "time",
                "deadline"
              ],
              "emoji": "⏱"
            },
            {
              "keywords": [
                "alarm"
              ],
              "emoji": "⏲"
            },
            {
              "keywords": [
                "time",
                "wake"
              ],
              "emoji": "⏰"
            },
             {
              "keywords": [
                "time"
              ],
              "emoji": "🕰"
            },
            {
              "keywords": [
                "oldschool",
                "time",
                "countdown"
              ],
              "emoji": "⏳"
            },
            {
              "keywords": [
                "time",
                "clock",
                "oldschool",
                "limit",
                "exam",
                "quiz",
                "test"
              ],
              "emoji": "⌛"
            },
            {
              "keywords": [
                "communication",
                "future",
                "radio",
                "space"
              ],
              "emoji": "📡"
            },
             {
              "keywords": [
                "power",
                "energy",
                "sustain"
              ],
              "emoji": "🔋"
            },
             {
              "keywords": [
                "charger",
                "power"
              ],
              "emoji": "🔌"
            },
             {
              "keywords": [
                "light",
                "electricity",
                "idea"
              ],
              "emoji": "💡"
            },
             {
              "keywords": [
                "dark",
                "camping",
                "sight",
                "night"
              ],
              "emoji": "🔦"
            },
             {
              "keywords": [
                "fire",
                "wax"
              ],
              "emoji": "🕯"
            },
            {
              "keywords": [
                "quench"
              ],
              "emoji": "🧯"
            },
            {
              "keywords": [
                "bin",
                "trash",
                "rubbish",
                "garbage",
                "toss"
              ],
              "emoji": "🗑"
            },
            {
              "keywords": [
                "barrell"
              ],
              "emoji": "🛢"
            },
            {
              "keywords": [
                "dollar",
                "bills",
                "payment",
                "sale"
              ],
              "emoji": "💸"
            },
            {
              "keywords": [
                "money",
                "sales",
                "bill",
                "currency"
              ],
              "emoji": "💵"
            },
             {
              "keywords": [
                "money",
                "sales",
                "japanese",
                "dollar",
                "currency"
              ],
              "emoji": "💴"
            },
            {
              "keywords": [
                "money",
                "sales",
                "dollar",
                "currency"
              ],
              "emoji": "💶"
            },
            {
              "keywords": [
                "british",
                "sterling",
                "money",
                "sales",
                "bills",
                "uk",
                "england",
                "currency"
              ],
              "emoji": "💷"
            },
             {
              "keywords": [
                "dollar",
                "payment",
                "coins",
                "sale"
              ],
              "emoji": "💰"
            },
            {
              "keywords": [
                "money",
                "sales",
                "dollar",
                "bill",
                "payment",
                "shopping"
              ],
              "emoji": "💳"
            },
            {
              "keywords": [
                "blue",
                "ruby",
                "diamond",
                "jewelry"
              ],
              "emoji": "💎"
            },
            {
              "keywords": [
                "law",
                "fairness",
                "weight"
              ],
              "emoji": "⚖"
            },
            {
              "keywords": [
                "tools",
                "diy",
                "fix",
                "maintainer",
                "mechanic"
              ],
              "emoji": "🧰"
            },
             {
              "keywords": [
                "tools",
                "diy",
                "ikea",
                "fix",
                "maintainer"
              ],
              "emoji": "🔧"
            },
             {
              "keywords": [
                "tools",
                "build",
                "create"
              ],
              "emoji": "🔨"
            },
             {
              "keywords": [
                "tools",
                "build",
                "create"
              ],
              "emoji": "⚒"
            },
            {
              "keywords": [
                "tools",
                "build",
                "create"
              ],
              "emoji": "🛠"
            },
             {
              "keywords": [
                "tools",
                "dig"
              ],
              "emoji": "⛏"
            },
             {
              "keywords": [
                "handy",
                "tools",
                "fix"
              ],
              "emoji": "🔩"
            },
             {
              "keywords": [
                "cog"
              ],
              "emoji": "⚙"
            },
             {
              "keywords": [
                "bricks"
              ],
              "emoji": "🧱"
            },
             {
              "keywords": [
                "lock",
                "arrest"
              ],
              "emoji": "⛓"
            },
            {
              "keywords": [
                "attraction",
                "magnetic"
              ],
              "emoji": "🧲"
            },
             {
              "keywords": [
                "violence",
                "weapon",
                "pistol",
                "revolver"
              ],
              "emoji": "🔫"
            },
            {
              "keywords": [
                "boom",
                "explode",
                "explosion",
                "terrorism"
              ],
              "emoji": "💣"
            },
            {
              "keywords": [
                "dynamite",
                "boom",
                "explode",
                "explosion",
                "explosive"
              ],
              "emoji": "🧨"
            },
            {
              "keywords": [
                "knife",
                "blade",
                "cutlery",
                "kitchen",
                "weapon"
              ],
              "emoji": "🔪"
            },
             {
              "keywords": [
                "weapon"
              ],
              "emoji": "🗡"
            },
            {
              "keywords": [
                "weapon"
              ],
              "emoji": "⚔"
            },
            {
              "keywords": [
                "protection",
                "security"
              ],
              "emoji": "🛡"
            },
            {
              "keywords": [
                "kills",
                "tobacco",
                "cigarette",
                "joint",
                "smoke"
              ],
              "emoji": "🚬"
            },
             {
              "keywords": [
                "poison",
                "danger",
                "deadly",
                "scary",
                "death",
                "pirate",
                "evil"
              ],
              "emoji": "☠"
            },
             {
              "keywords": [
                "vampire",
                "dead",
                "die",
                "death",
                "rip",
                "graveyard",
                "cemetery",
                "casket",
                "funeral",
                "box"
              ],
              "emoji": "⚰"
            },
             {
              "keywords": [
                "dead",
                "die",
                "death",
                "rip",
                "ashes"
              ],
              "emoji": "⚱"
            },
            {
              "keywords": [
                "vase",
                "jar"
              ],
              "emoji": "🏺"
            },
            {
              "keywords": [
                "disco",
                "party",
                "magic",
                "circus",
                "fortune_teller"
              ],
              "emoji": "🔮"
            },
            {
              "keywords": [
                "dhikr",
                "religious"
              ],
              "emoji": "📿"
            },
            {
              "keywords": [
                "bead",
                "charm"
              ],
              "emoji": "🧿"
            },
            {
              "keywords": [
                "hair",
                "salon",
                "style"
              ],
              "emoji": "💈"
            },
            {
              "keywords": [
                "distilling",
                "science",
                "experiment",
                "chemistry"
              ],
              "emoji": "⚗"
            },
            {
              "keywords": [
                "stars",
                "space",
                "zoom",
                "science",
                "astronomy"
              ],
              "emoji": "🔭"
            },
            {
              "keywords": [
                "laboratory",
                "experiment",
                "zoomin",
                "science",
                "study"
              ],
              "emoji": "🔬"
            },
            {
              "keywords": [
                "embarrassing"
              ],
              "emoji": "🕳"
            },
            {
              "keywords": [
                "health",
                "medicine",
                "doctor",
                "pharmacy",
                "drug"
              ],
              "emoji": "💊"
            },
            {
              "keywords": [
                "health",
                "hospital",
                "drugs",
                "blood",
                "medicine",
                "needle",
                "doctor",
                "nurse"
              ],
              "emoji": "💉"
            },
            {
              "keywords": [
                "biologist",
                "genetics",
                "life"
              ],
              "emoji": "🧬"
            },
            {
              "keywords": [
                "amoeba",
                "bacteria",
                "germs"
              ],
              "emoji": "🦠"
            },
            {
              "keywords": [
                "bacteria",
                "biology",
                "culture",
                "lab"
              ],
              "emoji": "🧫"
            },
            {
              "keywords": [
                "chemistry",
                "experiment",
                "lab",
                "science"
              ],
              "emoji": "🧪"
            },
            {
              "keywords": [
                "weather",
                "temperature",
                "hot",
                "cold"
              ],
              "emoji": "🌡"
            },
             {
              "keywords": [
                "cleaning",
                "sweeping",
                "witch"
              ],
              "emoji": "🧹"
            },
             {
              "keywords": [
                "laundry"
              ],
              "emoji": "🧺"
            },
            {
              "keywords": [
                "roll"
              ],
              "emoji": "🧻"
            },
             {
              "keywords": [
                "sale",
                "tag"
              ],
              "emoji": "🏷"
            },
            {
              "keywords": [
                "favorite",
                "label",
                "save"
              ],
              "emoji": "🔖"
            },
            {
              "keywords": [
                "restroom",
                "wc",
                "washroom",
                "bathroom",
                "potty"
              ],
              "emoji": "🚽"
            },
            {
              "keywords": [
                "clean",
                "water",
                "bathroom"
              ],
              "emoji": "🚿"
            },
            {
              "keywords": [
                "clean",
                "shower",
                "bathroom"
              ],
              "emoji": "🛁"
            },
            {
              "keywords": [
                "bar",
                "bathing",
                "cleaning",
                "lather"
              ],
              "emoji": "🧼"
            },
            {
              "keywords": [
                "absorbing",
                "cleaning",
                "porous"
              ],
              "emoji": "🧽"
            },
             {
              "keywords": [
                "moisturizer",
                "sunscreen"
              ],
              "emoji": "🧴"
            },
            {
              "keywords": [
                "lock",
                "door",
                "password"
              ],
              "emoji": "🔑"
            },
             {
              "keywords": [
                "lock",
                "door",
                "password"
              ],
              "emoji": "🗝"
            },
             {
              "keywords": [
                "read",
                "chill"
              ],
              "emoji": "🛋"
            },
             {
              "keywords": [
                "bed",
                "rest"
              ],
              "emoji": "🛌"
            },
             {
              "keywords": [
                "sleep",
                "rest"
              ],
              "emoji": "🛏"
            },
            {
              "keywords": [
                "house",
                "entry",
                "exit"
              ],
              "emoji": "🚪"
            },
             {
              "keywords": [
                "service"
              ],
              "emoji": "🛎"
            },
            {
              "keywords": [
                "plush",
                "stuffed"
              ],
              "emoji": "🧸"
            },
             {
              "keywords": [
                "photography"
              ],
              "emoji": "🖼"
            },
            {
              "keywords": [
                "location",
                "direction"
              ],
              "emoji": "🗺"
            },
            {
              "keywords": [
                "weather",
                "summer"
              ],
              "emoji": "⛱"
            },
             {
              "keywords": [
                "rock",
                "easter island",
                "moai"
              ],
              "emoji": "🗿"
            },
            {
              "keywords": [
                "mall",
                "buy",
                "purchase"
              ],
              "emoji": "🛍"
            },
            {
              "keywords": [
                "trolley"
              ],
              "emoji": "🛒"
            },
            {
              "keywords": [
                "party",
                "celebration",
                "birthday",
                "circus"
              ],
              "emoji": "🎈"
            },
            {
              "keywords": [
                "fish",
                "japanese",
                "koinobori",
                "carp",
                "banner"
              ],
              "emoji": "🎏"
            },
             {
              "keywords": [
                "decoration",
                "pink",
                "girl",
                "bowtie"
              ],
              "emoji": "🎀"
            },
            {
              "keywords": [
                "present",
                "birthday",
                "christmas",
                "xmas"
              ],
              "emoji": "🎁"
            },
            {
              "keywords": [
                "festival",
                "party",
                "birthday",
                "circus"
              ],
              "emoji": "🎊"
            },
            {
              "keywords": [
                "party",
                "congratulations",
                "birthday",
                "magic",
                "circus",
                "celebration"
              ],
              "emoji": "🎉"
            },
            {
              "keywords": [
                "japanese",
                "toy",
                "kimono"
              ],
              "emoji": "🎎"
            },
            {
              "keywords": [
                "nature",
                "ding",
                "spring",
                "bell"
              ],
              "emoji": "🎐"
            },
             {
              "keywords": [
                "japanese",
                "nation",
                "country",
                "border"
              ],
              "emoji": "🎌"
            },
             {
              "keywords": [
                "light",
                "paper",
                "halloween",
                "spooky"
              ],
              "emoji": "🏮"
            },
            {
              "keywords": [
                "gift"
              ],
              "emoji": "🧧"
            },
            {
              "keywords": [
                "letter",
                "postal",
                "inbox",
                "communication"
              ],
              "emoji": "✉️"
            },
            {
              "keywords": [
                "email",
                "communication"
              ],
              "emoji": "📩"
            },
            {
              "keywords": [
                "email",
                "inbox"
              ],
              "emoji": "📨"
            },
            {
              "keywords": [
                "communication",
                "inbox"
              ],
              "emoji": "📧"
            },
            {
              "keywords": [
                "email",
                "like",
                "affection",
                "envelope",
                "valentines"
              ],
              "emoji": "💌"
            },
            {
              "keywords": [
                "email",
                "letter",
                "envelope"
              ],
              "emoji": "📮"
            },
            {
              "keywords": [
                "email",
                "communication",
                "inbox"
              ],
              "emoji": "📪"
            },
             {
              "keywords": [
                "email",
                "inbox",
                "communication"
              ],
              "emoji": "📫"
            },
             {
              "keywords": [
                "email",
                "inbox",
                "communication"
              ],
              "emoji": "📬"
            },
            {
              "keywords": [
                "email",
                "inbox"
              ],
              "emoji": "📭"
            },
             {
              "keywords": [
                "mail",
                "gift",
                "cardboard",
                "box",
                "moving"
              ],
              "emoji": "📦"
            },
             {
              "keywords": [
                "instrument",
                "music"
              ],
              "emoji": "📯"
            },
             {
              "keywords": [
                "email",
                "documents"
              ],
              "emoji": "📥"
            },
             {
              "keywords": [
                "inbox",
                "email"
              ],
              "emoji": "📤"
            },
             {
              "keywords": [
                "documents",
                "ancient",
                "history",
                "paper"
              ],
              "emoji": "📜"
            },
             {
              "keywords": [
                "documents",
                "office",
                "paper"
              ],
              "emoji": "📃"
            },
             {
              "keywords": [
                "favorite",
                "save",
                "order",
                "tidy"
              ],
              "emoji": "📑"
            },
            {
              "keywords": [
                "accounting",
                "expenses"
              ],
              "emoji": "🧾"
            },
            {
              "keywords": [
                "graph",
                "presentation",
                "stats"
              ],
              "emoji": "📊"
            },
             {
              "keywords": [
                "graph",
                "presentation",
                "stats",
                "recovery",
                "business",
                "economics",
                "money",
                "sales",
                "good",
                "success"
              ],
              "emoji": "📈"
            },
            {
              "keywords": [
                "graph",
                "presentation",
                "stats",
                "recession",
                "business",
                "economics",
                "money",
                "sales",
                "bad",
                "failure"
              ],
              "emoji": "📉"
            },
            {
              "keywords": [
                "documents",
                "office",
                "paper",
                "information"
              ],
              "emoji": "📄"
            },
             {
              "keywords": [
                "calendar",
                "schedule"
              ],
              "emoji": "📅"
            },
            {
              "keywords": [
                "schedule",
                "date",
                "planning"
              ],
              "emoji": "📆"
            },
             {
              "keywords": [
                "date",
                "schedule",
                "planning"
              ],
              "emoji": "🗓"
            },
            {
              "keywords": [
                "business",
                "stationery"
              ],
              "emoji": "📇"
            },
            {
              "keywords": [
                "business",
                "stationery"
              ],
              "emoji": "🗃"
            },
             {
              "keywords": [
                "election",
                "vote"
              ],
              "emoji": "🗳"
            },
             {
              "keywords": [
                "filing",
                "organizing"
              ],
              "emoji": "🗄"
            },
            {
              "keywords": [
                "stationery",
                "documents"
              ],
              "emoji": "📋"
            },
            {
              "keywords": [
                "memo",
                "stationery"
              ],
              "emoji": "🗒"
            },
             {
              "keywords": [
                "documents",
                "business",
                "office"
              ],
              "emoji": "📁"
            },
             {
              "keywords": [
                "documents",
                "load"
              ],
              "emoji": "📂"
            },
            {
              "keywords": [
                "organizing",
                "business",
                "stationery"
              ],
              "emoji": "🗂"
            },
            {
              "keywords": [
                "press",
                "headline"
              ],
              "emoji": "🗞"
            },
            {
              "keywords": [
                "press",
                "headline"
              ],
              "emoji": "📰"
            },
            {
              "keywords": [
                "stationery",
                "record",
                "notes",
                "paper",
                "study"
              ],
              "emoji": "📓"
            },
            {
              "keywords": [
                "read",
                "library",
                "knowledge",
                "textbook",
                "learn"
              ],
              "emoji": "📕"
            },
            {
              "keywords": [
                "read",
                "library",
                "knowledge",
                "study"
              ],
              "emoji": "📗"
            },
            {
              "keywords": [
                "read",
                "library",
                "knowledge",
                "learn",
                "study"
              ],
              "emoji": "📘"
            },
             {
              "keywords": [
                "read",
                "library",
                "knowledge",
                "textbook",
                "study"
              ],
              "emoji": "📙"
            },
            {
              "keywords": [
                "classroom",
                "notes",
                "record",
                "paper",
                "study"
              ],
              "emoji": "📔"
            },
             {
              "keywords": [
                "notes",
                "paper"
              ],
              "emoji": "📒"
            },
            {
              "keywords": [
                "literature",
                "library",
                "study"
              ],
              "emoji": "📚"
            },
            {
              "keywords": [
                "book",
                "read",
                "library",
                "knowledge",
                "literature",
                "learn",
                "study"
              ],
              "emoji": "📖"
            },
             {
              "keywords": [
                "diaper"
              ],
              "emoji": "🧷"
            },
             {
              "keywords": [
                "rings",
                "url"
              ],
              "emoji": "🔗"
            },
            {
              "keywords": [
                "documents",
                "stationery"
              ],
              "emoji": "📎"
            },
             {
              "keywords": [
                "documents",
                "stationery"
              ],
              "emoji": "🖇"
            },
             {
              "keywords": [
                "stationery",
                "cut"
              ],
              "emoji": "✂️"
            },
            {
              "keywords": [
                "stationery",
                "math",
                "architect",
                "sketch"
              ],
              "emoji": "📐"
            },
            {
              "keywords": [
                "stationery",
                "calculate",
                "length",
                "math",
                "school",
                "drawing",
                "architect",
                "sketch"
              ],
              "emoji": "📏"
            },
            {
              "keywords": [
                "calculation"
              ],
              "emoji": "🧮"
            },
            {
              "keywords": [
                "stationery",
                "mark",
                "here"
              ],
              "emoji": "📌"
            },
            {
              "keywords": [
                "stationery",
                "location",
                "map",
                "here"
              ],
              "emoji": "📍"
            },
            {
              "keywords": [
                "mark",
                "milestone",
                "place"
              ],
              "emoji": "🚩"
            },
            {
              "keywords": [
                "losing",
                "loser",
                "lost",
                "surrender",
                "give up",
                "fail"
              ],
              "emoji": "🏳"
            },
             {
              "keywords": [
                "pirate"
              ],
              "emoji": "🏴"
            },
            {
              "keywords": [
                "flag",
                "rainbow",
                "pride",
                "gay",
                "lgbt",
                "glbt",
                "queer",
                "homosexual",
                "lesbian",
                "bisexual",
                "transgender"
              ],
              "emoji": "🏳️‍🌈"
            },
             {
              "keywords": [
                "security",
                "privacy"
              ],
              "emoji": "🔐"
            },
             {
              "keywords": [
                "security",
                "password",
                "padlock"
              ],
              "emoji": "🔒"
            },
            {
              "keywords": [
                "privacy",
                "security"
              ],
              "emoji": "🔓"
            },
             {
              "keywords": [
                "security",
                "secret"
              ],
              "emoji": "🔏"
            },
            {
              "keywords": [
                "stationery",
                "writing",
                "write"
              ],
              "emoji": "🖊"
            },
             {
              "keywords": [
                "stationery",
                "writing",
                "write"
              ],
              "emoji": "🖋"
            },
             {
              "keywords": [
                "pen",
                "stationery",
                "writing",
                "write"
              ],
              "emoji": "✒️"
            },
            {
              "keywords": [
                "write",
                "documents",
                "stationery",
                "pencil",
                "paper",
                "writing",
                "legal",
                "exam",
                "quiz",
                "test",
                "study",
                "compose"
              ],
              "emoji": "📝"
            },
            {
              "keywords": [
                "stationery",
                "write",
                "paper",
                "writing",
                "school",
                "study"
              ],
              "emoji": "✏️"
            },
            {
              "keywords": [
                "drawing",
                "creativity"
              ],
              "emoji": "🖍"
            },
             {
              "keywords": [
                "drawing",
                "creativity",
                "art"
              ],
              "emoji": "🖌"
            },
            {
              "keywords": [
                "search",
                "zoom",
                "find",
                "detective"
              ],
              "emoji": "🔍"
            },
            {
              "keywords": [
                "search",
                "zoom",
                "find",
                "detective"
              ],
              "emoji": "🔎"
            }
          ]
      },
                     {
                         "id": "symbols",
                         "name": "symbols",
                         "symbol": "messages-emoji-keyboard-animals",
                         "emojis": [
                           {
                             "keywords": ["love", "like", "valentines"],
                             "emoji": "❤️"
                           },
                           {
                             "keywords": ["love", "like", "affection", "valentines"],
                             "emoji": "🧡"
                           },
                           {
                             "keywords": ["love", "like", "affection", "valentines"],
                             "emoji": "💛"
                           },
                           {
                             "keywords": ["love", "like", "affection", "valentines"],
                             "emoji": "💚"
                           },
                           {
                             "keywords": ["love", "like", "affection", "valentines"],
                             "emoji": "💙"
                           },
                           {
                             "keywords": ["love", "like", "affection", "valentines"],
                             "emoji": "💜"
                           },
                           {
                             "keywords": ["evil"],
                             "emoji": "🖤"
                           },
                           {
                             "keywords": ["sad", "sorry", "break", "heart", "heartbreak"],
                             "emoji": "💔"
                           },
                           {
                             "keywords": ["decoration", "love"],
                             "emoji": "❣"
                           },
                           {
                             "keywords": ["love", "like", "affection", "valentines", "heart"],
                             "emoji": "💕"
                           },
                           {
                             "keywords": ["love", "like", "affection", "valentines"],
                             "emoji": "💞"
                           },
                           {
                             "keywords": [
                               "love",
                               "like",
                               "affection",
                               "valentines",
                               "pink",
                               "heart"
                             ],
                             "emoji": "💓"
                           },
                           {
                             "keywords": ["like", "love", "affection", "valentines", "pink"],
                             "emoji": "💗"
                           },
                           {
                             "keywords": ["love", "like", "affection", "valentines"],
                             "emoji": "💖"
                           },
                           {
                             "keywords": ["love", "like", "heart", "affection", "valentines"],
                             "emoji": "💘"
                           },
                           {
                             "keywords": ["love", "valentines"],
                             "emoji": "💝"
                           },
                           {
                             "keywords": ["purple-square", "love", "like"],
                             "emoji": "💟"
                           },
                           {
                             "keywords": ["hippie"],
                             "emoji": "☮"
                           },
                           {
                             "keywords": ["christianity"],
                             "emoji": "✝"
                           },
                           {
                             "keywords": ["islam"],
                             "emoji": "☪"
                           },
                           {
                             "keywords": ["hinduism", "buddhism", "sikhism", "jainism"],
                             "emoji": "🕉"
                           },
                           {
                             "keywords": ["hinduism", "buddhism", "sikhism", "jainism"],
                             "emoji": "☸"
                           },
                           {
                             "keywords": ["judaism"],
                             "emoji": "✡"
                           },
                           {
                             "keywords": ["purple-square", "religion", "jewish", "hexagram"],
                             "emoji": "🔯"
                           },
                           {
                             "keywords": ["hanukkah", "candles", "jewish"],
                             "emoji": "🕎"
                           },
                            {
                             "keywords": ["balance"],
                             "emoji": "☯"
                           },
                            {
                             "keywords": ["suppedaneum", "religion"],
                             "emoji": "☦"
                           },
                            {
                             "keywords": ["religion", "church", "temple", "prayer"],
                             "emoji": "🛐"
                           },
                            {
                             "keywords": ["sign", "purple-square", "constellation", "astrology"],
                             "emoji": "⛎"
                           },
                           {
                             "keywords": ["sign", "purple-square", "zodiac", "astrology"],
                             "emoji": "♈"
                           },
                            {
                             "keywords": ["purple-square", "sign", "zodiac", "astrology"],
                             "emoji": "♉"
                           },
                            {
                             "keywords": ["sign", "zodiac", "purple-square", "astrology"],
                             "emoji": "♊"
                           },
                           {
                             "keywords": ["sign", "zodiac", "purple-square", "astrology"],
                             "emoji": "♋"
                           },
                           {
                             "keywords": ["sign", "purple-square", "zodiac", "astrology"],
                             "emoji": "♌"
                           },
                            {
                             "keywords": ["sign", "zodiac", "purple-square", "astrology"],
                             "emoji": "♍"
                           },
                           {
                             "keywords": ["sign", "purple-square", "zodiac", "astrology"],
                             "emoji": "♎"
                           },
                           {
                             "keywords": ["sign", "zodiac", "purple-square", "astrology", "scorpio"],
                             "emoji": "♏"
                           },
                           {
                             "keywords": ["sign", "zodiac", "purple-square", "astrology"],
                             "emoji": "♐"
                           },
                           {
                             "keywords": ["sign", "zodiac", "purple-square", "astrology"],
                             "emoji": "♑"
                           },
                           {
                             "keywords": ["sign", "purple-square", "zodiac", "astrology"],
                             "emoji": "♒"
                           },
                           {
                             "keywords": ["purple-square", "sign", "zodiac", "astrology"],
                             "emoji": "♓"
                           },
                           {
                             "keywords": ["purple-square", "words"],
                             "emoji": "🆔"
                           },
                           {
                             "keywords": ["science", "physics", "chemistry"],
                             "emoji": "⚛"
                           },
                            {
                             "keywords": [
                               "kanji",
                               "japanese",
                               "chinese",
                               "empty",
                               "sky",
                               "blue-square"
                             ],
                             "emoji": "🈳"
                           },
                           {
                             "keywords": ["cut", "divide", "chinese", "kanji", "pink-square"],
                             "emoji": "🈹"
                           },
                           {
                             "keywords": ["nuclear", "danger"],
                             "emoji": "☢"
                           },
                           {
                             "keywords": ["danger"],
                             "emoji": "☣"
                           },
                           {
                             "keywords": ["mute", "orange-square", "silence", "quiet"],
                             "emoji": "📴"
                           },
                            {
                             "keywords": ["orange-square", "phone"],
                             "emoji": "📳"
                           },
                           {
                             "keywords": ["orange-square", "chinese", "have", "kanji"],
                             "emoji": "🈶"
                           },
                            {
                             "keywords": [
                               "nothing",
                               "chinese",
                               "kanji",
                               "japanese",
                               "orange-square"
                             ],
                             "emoji": "🈚"
                           },
                           {
                             "keywords": ["chinese", "japanese", "kanji", "orange-square"],
                             "emoji": "🈸"
                           },
                           {
                             "keywords": ["japanese", "opening hours", "orange-square"],
                             "emoji": "🈺"
                           },
                           {
                             "keywords": [
                               "chinese",
                               "month",
                               "moon",
                               "japanese",
                               "orange-square",
                               "kanji"
                             ],
                             "emoji": "🈷️"
                           },
                            {
                             "keywords": ["orange-square", "shape", "polygon"],
                             "emoji": "✴️"
                           },
                           {
                             "keywords": ["words", "orange-square"],
                             "emoji": "🆚"
                           },
                            {
                             "keywords": [
                               "ok",
                               "good",
                               "chinese",
                               "kanji",
                               "agree",
                               "yes",
                               "orange-circle"
                             ],
                             "emoji": "🉑"
                           },
                           {
                             "keywords": ["japanese", "spring"],
                             "emoji": "💮"
                           },
                           {
                             "keywords": ["chinese", "kanji", "obtain", "get", "circle"],
                             "emoji": "🉐"
                           },
                           {
                             "keywords": ["privacy", "chinese", "sshh", "kanji", "red-circle"],
                             "emoji": "㊙️"
                           },
                           {
                             "keywords": ["chinese", "kanji", "japanese", "red-circle"],
                             "emoji": "㊗️"
                           },
                           {
                             "keywords": ["japanese", "chinese", "join", "kanji", "red-square"],
                             "emoji": "🈴"
                           },
                           {
                             "keywords": ["full", "chinese", "japanese", "red-square", "kanji"],
                             "emoji": "🈵"
                           },
                           {
                             "keywords": [
                               "kanji",
                               "japanese",
                               "chinese",
                               "forbidden",
                               "limit",
                               "restricted",
                               "red-square"
                             ],
                             "emoji": "🈲"
                           },
                           {
                             "keywords": ["red-square", "alphabet", "letter"],
                             "emoji": "🅰️"
                           },
                            {
                             "keywords": ["red-square", "alphabet", "letter"],
                             "emoji": "🅱️"
                           },
                            {
                             "keywords": ["red-square", "alphabet"],
                             "emoji": "🆎"
                           },
                           {
                             "keywords": ["alphabet", "words", "red-square"],
                             "emoji": "🆑"
                           },
                           {
                             "keywords": ["alphabet", "red-square", "letter"],
                             "emoji": "🅾️"
                           },
                           {
                             "keywords": ["help", "red-square", "words", "emergency", "911"],
                             "emoji": "🆘"
                           },
                            {
                             "keywords": [
                               "limit",
                               "security",
                               "privacy",
                               "bad",
                               "denied",
                               "stop",
                               "circle"
                             ],
                             "emoji": "⛔"
                           },
                           {
                             "keywords": ["fire", "forbid"],
                             "emoji": "📛"
                           },
                           {
                             "keywords": ["forbid", "stop", "limit", "denied", "disallow", "circle"],
                             "emoji": "🚫"
                           },
                            {
                             "keywords": ["no", "delete", "remove", "cancel", "red"],
                             "emoji": "❌"
                           },
                           {
                             "keywords": ["circle", "round"],
                             "emoji": "⭕"
                           },
                           {
                             "keywords": ["stop"],
                             "emoji": "🛑"
                           },
                            {
                             "keywords": ["angry", "mad"],
                             "emoji": "💢"
                           },
                           {
                             "keywords": ["bath", "warm", "relax"],
                             "emoji": "♨️"
                           },
                            {
                             "keywords": ["rules", "crossing", "walking", "circle"],
                             "emoji": "🚷"
                           },
                           {
                             "keywords": ["trash", "bin", "garbage", "circle"],
                             "emoji": "🚯"
                           },
                           {
                             "keywords": ["cyclist", "prohibited", "circle"],
                             "emoji": "🚳"
                           },
                            {
                             "keywords": ["drink", "faucet", "tap", "circle"],
                             "emoji": "🚱"
                           },
                            {
                             "keywords": ["18", "drink", "pub", "night", "minor", "circle"],
                             "emoji": "🔞"
                           },
                           {
                             "keywords": ["iphone", "mute", "circle"],
                             "emoji": "📵"
                           },
                            {
                             "keywords": [
                               "heavy_exclamation_mark",
                               "danger",
                               "surprise",
                               "punctuation",
                               "wow",
                               "warning"
                             ],
                             "emoji": "❗"
                           },
                            {
                             "keywords": ["surprise", "punctuation", "gray", "wow", "warning"],
                             "emoji": "❕"
                           },
                           {
                             "keywords": ["doubt", "confused"],
                             "emoji": "❓"
                           },
                           {
                             "keywords": ["doubts", "gray", "huh", "confused"],
                             "emoji": "❔"
                           },
                           {
                             "keywords": ["exclamation", "surprise"],
                             "emoji": "‼️"
                           },
                            {
                             "keywords": ["wat", "punctuation", "surprise"],
                             "emoji": "⁉️"
                           },
                           {
                             "keywords": [
                               "score",
                               "perfect",
                               "numbers",
                               "century",
                               "exam",
                               "quiz",
                               "test",
                               "pass",
                               "hundred"
                             ],
                             "emoji": "💯"
                           },
                            {
                             "keywords": ["sun", "afternoon", "warm", "summer"],
                             "emoji": "🔅"
                           },
                           {
                             "keywords": ["sun", "light"],
                             "emoji": "🔆"
                           },
                           {
                             "keywords": ["weapon", "spear"],
                             "emoji": "🔱"
                           },
                            {
                             "keywords": ["decorative", "scout"],
                             "emoji": "⚜"
                           },
                           {
                             "keywords": [
                               "graph",
                               "presentation",
                               "stats",
                               "business",
                               "economics",
                               "bad"
                             ],
                             "emoji": "〽️"
                           },
                            {
                             "keywords": [
                               "exclamation",
                               "wip",
                               "alert",
                               "error",
                               "problem",
                               "issue"
                             ],
                             "emoji": "⚠️"
                           },
                           {
                             "keywords": [
                               "school",
                               "warning",
                               "danger",
                               "sign",
                               "driving",
                               "yellow-diamond"
                             ],
                             "emoji": "🚸"
                           },
                            {
                             "keywords": ["badge", "shield"],
                             "emoji": "🔰"
                           },
                            {
                             "keywords": ["arrow", "environment", "garbage", "trash"],
                             "emoji": "♻️"
                           },
                           {
                             "keywords": ["chinese", "point", "green-square", "kanji"],
                             "emoji": "🈯"
                           },
                            {
                             "keywords": ["green-square", "graph", "presentation", "stats"],
                             "emoji": "💹"
                           },
                           {
                             "keywords": ["stars", "green-square", "awesome", "good", "fireworks"],
                             "emoji": "❇️"
                           },
                            {
                             "keywords": ["star", "sparkle", "green-square"],
                             "emoji": "✳️"
                           },
                            {
                             "keywords": ["x", "green-square", "no", "deny"],
                             "emoji": "❎"
                           },
                           {
                             "keywords": [
                               "green-square",
                               "ok",
                               "agree",
                               "vote",
                               "election",
                               "answer",
                               "tick"
                             ],
                             "emoji": "✅"
                           },
                            {
                             "keywords": ["jewel", "blue", "gem", "crystal", "fancy"],
                             "emoji": "💠"
                           },
                            {
                             "keywords": [
                               "weather",
                               "swirl",
                               "blue",
                               "cloud",
                               "vortex",
                               "spiral",
                               "whirlpool",
                               "spin",
                               "tornado",
                               "hurricane",
                               "typhoon"
                             ],
                             "emoji": "🌀"
                           },
                           {
                             "keywords": ["tape", "cassette"],
                             "emoji": "➿"
                           },
                           {
                             "keywords": [
                               "earth",
                               "international",
                               "world",
                               "internet",
                               "interweb",
                               "i18n"
                             ],
                             "emoji": "🌐"
                           },
                            {
                             "keywords": ["alphabet", "blue-circle", "letter"],
                             "emoji": "Ⓜ️"
                           },
                           {
                             "keywords": [
                               "money",
                               "sales",
                               "cash",
                               "blue-square",
                               "payment",
                               "bank"
                             ],
                             "emoji": "🏧"
                           },
                           {
                             "keywords": ["japanese", "blue-square", "katakana"],
                             "emoji": "🈂️"
                           },
                           {
                             "keywords": ["custom", "blue-square"],
                             "emoji": "🛂"
                           },
                           {
                             "keywords": ["passport", "border", "blue-square"],
                             "emoji": "🛃"
                           },
                           {
                             "keywords": ["blue-square", "airport", "transport"],
                             "emoji": "🛄"
                           },
                           {
                             "keywords": ["blue-square", "travel"],
                             "emoji": "🛅"
                           },
                           {
                             "keywords": ["blue-square", "disabled", "a11y", "accessibility"],
                             "emoji": "♿"
                           },
                            {
                             "keywords": ["cigarette", "blue-square", "smell", "smoke"],
                             "emoji": "🚭"
                           },
                            {
                             "keywords": ["toilet", "restroom", "blue-square"],
                             "emoji": "🚾"
                           },
                            {
                             "keywords": ["cars", "blue-square", "alphabet", "letter"],
                             "emoji": "🅿️"
                           },
                           {
                             "keywords": ["blue-square", "liquid", "restroom", "cleaning", "faucet"],
                             "emoji": "🚰"
                           },
                            {
                             "keywords": [
                               "toilet",
                               "restroom",
                               "wc",
                               "blue-square",
                               "gender",
                               "male"
                             ],
                             "emoji": "🚹"
                           },
                            {
                             "keywords": [
                               "purple-square",
                               "woman",
                               "female",
                               "toilet",
                               "loo",
                               "restroom",
                               "gender"
                             ],
                             "emoji": "🚺"
                           },
                           {
                             "keywords": ["orange-square", "child"],
                             "emoji": "🚼"
                           },
                           {
                             "keywords": ["blue-square", "toilet", "refresh", "wc", "gender"],
                             "emoji": "🚻"
                           },
                           {
                             "keywords": ["blue-square", "sign", "human", "info"],
                             "emoji": "🚮"
                           },
                           {
                             "keywords": [
                               "blue-square",
                               "record",
                               "film",
                               "movie",
                               "curtain",
                               "stage",
                               "theater"
                             ],
                             "emoji": "🎦"
                           },
                            {
                             "keywords": [
                               "blue-square",
                               "reception",
                               "phone",
                               "internet",
                               "connection",
                               "wifi",
                               "bluetooth",
                               "bars"
                             ],
                             "emoji": "📶"
                           },
                           {
                             "keywords": [
                               "blue-square",
                               "here",
                               "katakana",
                               "japanese",
                               "destination"
                             ],
                             "emoji": "🈁"
                           },
                            {
                             "keywords": ["blue-square", "words", "shape", "icon"],
                             "emoji": "🆖"
                           },
                           {
                             "keywords": ["good", "agree", "yes", "blue-square"],
                             "emoji": "🆗"
                           },
                           {
                             "keywords": ["blue-square", "above", "high"],
                             "emoji": "🆙"
                           },
                            {
                             "keywords": ["words", "blue-square"],
                             "emoji": "🆒"
                           },
                           {
                             "keywords": ["blue-square", "words", "start"],
                             "emoji": "🆕"
                           },
                           {
                             "keywords": ["blue-square", "words"],
                             "emoji": "🆓"
                           },
                           {
                             "keywords": ["0", "numbers", "blue-square", "null"],
                             "emoji": "0️⃣"
                           },
                           {
                             "keywords": ["blue-square", "numbers", "1"],
                             "emoji": "1️⃣"
                           },
                            {
                             "keywords": ["numbers", "2", "prime", "blue-square"],
                             "emoji": "2️⃣"
                           },
                           {
                             "keywords": ["3", "numbers", "prime", "blue-square"],
                             "emoji": "3️⃣"
                           },
                           {
                             "keywords": ["4", "numbers", "blue-square"],
                             "emoji": "4️⃣"
                           },
                           {
                             "keywords": ["5", "numbers", "blue-square", "prime"],
                             "emoji": "5️⃣"
                           },
                           {
                             "keywords": ["6", "numbers", "blue-square"],
                             "emoji": "6️⃣"
                           },
                            {
                             "keywords": ["7", "numbers", "blue-square", "prime"],
                             "emoji": "7️⃣"
                           },
                            {
                             "keywords": ["8", "blue-square", "numbers"],
                             "emoji": "8️⃣"
                           },
                           {
                             "keywords": ["blue-square", "numbers", "9"],
                             "emoji": "9️⃣"
                           },
                            {
                             "keywords": ["numbers", "10", "blue-square"],
                             "emoji": "🔟"
                           },
                           {
                             "keywords": ["star", "keycap"],
                             "emoji": "*⃣"
                           },
                           {
                             "keywords": ["numbers", "blue-square"],
                             "emoji": "🔢"
                           },
                           {
                             "keywords": ["blue-square"],
                             "emoji": "⏏️"
                           },
                            {
                             "keywords": ["blue-square", "right", "direction", "play"],
                             "emoji": "▶️"
                           },
                           {
                             "keywords": ["pause", "blue-square"],
                             "emoji": "⏸"
                           },
                           {
                             "keywords": ["forward", "next", "blue-square"],
                             "emoji": "⏭"
                           },
                            {
                             "keywords": ["blue-square"],
                             "emoji": "⏹"
                           },
                           {
                             "keywords": ["blue-square"],
                             "emoji": "⏺"
                           },
                            {
                             "keywords": ["blue-square", "play", "pause"],
                             "emoji": "⏯"
                           },
                           {
                             "keywords": ["backward"],
                             "emoji": "⏮"
                           },
                            {
                             "keywords": ["blue-square", "play", "speed", "continue"],
                             "emoji": "⏩"
                           },
                            {
                             "keywords": ["play", "blue-square"],
                             "emoji": "⏪"
                           },
                           {
                             "keywords": ["blue-square", "shuffle", "music", "random"],
                             "emoji": "🔀"
                           },
                            {
                             "keywords": ["loop", "record"],
                             "emoji": "🔁"
                           },
                           {
                             "keywords": ["blue-square", "loop"],
                             "emoji": "🔂"
                           },
                           {
                             "keywords": ["blue-square", "left", "direction"],
                             "emoji": "◀️"
                           },
                           {
                             "keywords": [
                               "blue-square",
                               "triangle",
                               "direction",
                               "point",
                               "forward",
                               "top"
                             ],
                             "emoji": "🔼"
                           },
                           {
                             "keywords": ["blue-square", "direction", "bottom"],
                             "emoji": "🔽"
                           },
                           {
                             "keywords": ["blue-square", "direction", "top"],
                             "emoji": "⏫"
                           },
                           {
                             "keywords": ["blue-square", "direction", "bottom"],
                             "emoji": "⏬"
                           },
                            {
                             "keywords": ["blue-square", "next"],
                             "emoji": "➡️"
                           },
                           {
                             "keywords": ["blue-square", "previous", "back"],
                             "emoji": "⬅️"
                           },
                           {
                             "keywords": ["blue-square", "continue", "top", "direction"],
                             "emoji": "⬆️"
                           },
                            {
                             "keywords": ["blue-square", "direction", "bottom"],
                             "emoji": "⬇️"
                           },
                           {
                             "keywords": [
                               "blue-square",
                               "point",
                               "direction",
                               "diagonal",
                               "northeast"
                             ],
                             "emoji": "↗️"
                           },
                            {
                             "keywords": ["blue-square", "direction", "diagonal", "southeast"],
                             "emoji": "↘️"
                           },
                            {
                             "keywords": ["blue-square", "direction", "diagonal", "southwest"],
                             "emoji": "↙️"
                           },
                            {
                             "keywords": [
                               "blue-square",
                               "point",
                               "direction",
                               "diagonal",
                               "northwest"
                             ],
                             "emoji": "↖️"
                           },
                            {
                             "keywords": ["blue-square", "direction", "way", "vertical"],
                             "emoji": "↕️"
                           },
                           {
                             "keywords": ["shape", "direction", "horizontal", "sideways"],
                             "emoji": "↔️"
                           },
                            {
                             "keywords": ["blue-square", "sync", "cycle"],
                             "emoji": "🔄"
                           },
                           {
                             "keywords": ["blue-square", "return", "rotate", "direction"],
                             "emoji": "↪️"
                           },
                            {
                             "keywords": ["back", "return", "blue-square", "undo", "enter"],
                             "emoji": "↩️"
                           },
                           {
                             "keywords": ["blue-square", "direction", "top"],
                             "emoji": "⤴️"
                           },
                           {
                             "keywords": ["blue-square", "direction", "bottom"],
                             "emoji": "⤵️"
                           },
                            {
                             "keywords": ["symbol", "blue-square", "twitter"],
                             "emoji": "#️⃣"
                           },
                            {
                             "keywords": ["blue-square", "alphabet", "letter"],
                             "emoji": "ℹ️"
                           },
                            {
                             "keywords": ["blue-square", "alphabet"],
                             "emoji": "🔤"
                           },
                           {
                             "keywords": ["blue-square", "alphabet"],
                             "emoji": "🔡"
                           },
                            {
                             "keywords": ["alphabet", "words", "blue-square"],
                             "emoji": "🔠"
                           },
                           {
                             "keywords": [
                               "blue-square",
                               "music",
                               "note",
                               "ampersand",
                               "percent",
                               "glyphs",
                               "characters"
                             ],
                             "emoji": "🔣"
                           },
                           {
                             "keywords": ["score", "tone", "sound"],
                             "emoji": "🎵"
                           },
                           {
                             "keywords": ["music", "score"],
                             "emoji": "🎶"
                           },
                            {
                             "keywords": [
                               "draw",
                               "line",
                               "moustache",
                               "mustache",
                               "squiggle",
                               "scribble"
                             ],
                             "emoji": "〰️"
                           },
                            {
                             "keywords": ["scribble", "draw", "shape", "squiggle"],
                             "emoji": "➰"
                           },
                            {
                             "keywords": ["ok", "nike", "answer", "yes", "tick"],
                             "emoji": "✔️"
                           },
                            {
                             "keywords": ["sync", "cycle", "round", "repeat"],
                             "emoji": "🔃"
                           },
                            {
                             "keywords": ["math", "calculation", "addition", "more", "increase"],
                             "emoji": "➕"
                           },
                            {
                             "keywords": ["math", "calculation", "subtract", "less"],
                             "emoji": "➖"
                           },
                            {
                             "keywords": ["divide", "math", "calculation"],
                             "emoji": "➗"
                           },
                           {
                             "keywords": ["math", "calculation"],
                             "emoji": "✖️"
                           },
                           {
                             "keywords": ["forever"],
                             "emoji": "♾"
                           },
                           {
                             "keywords": ["money", "sales", "payment", "currency", "buck"],
                             "emoji": "💲"
                           },
                           {
                             "keywords": ["money", "sales", "dollar", "travel"],
                             "emoji": "💱"
                           },
                           {
                             "keywords": ["ip", "license", "circle", "law", "legal"],
                             "emoji": "©️"
                           },
                           {
                             "keywords": ["alphabet", "circle"],
                             "emoji": "®️"
                           },
                            {
                             "keywords": ["trademark", "brand", "law", "legal"],
                             "emoji": "™️"
                           },
                           {
                             "keywords": ["words", "arrow"],
                             "emoji": "🔚"
                           },
                           {
                             "keywords": ["arrow", "words", "return"],
                             "emoji": "🔙"
                           },
                            {
                             "keywords": ["arrow", "words"],
                             "emoji": "🔛"
                           },
                           {
                             "keywords": ["words", "blue-square"],
                             "emoji": "🔝"
                           },
                           {
                             "keywords": ["arrow", "words"],
                             "emoji": "🔜"
                           },
                            {
                             "keywords": [
                               "ok",
                               "agree",
                               "confirm",
                               "black-square",
                               "vote",
                               "election",
                               "yes",
                               "tick"
                             ],
                             "emoji": "☑️"
                           },
                           {
                             "keywords": ["input", "old", "music", "circle"],
                             "emoji": "🔘"
                           },
                           {
                             "keywords": ["shape", "round"],
                             "emoji": "⚪"
                           },
                            {
                             "keywords": ["shape", "button", "round"],
                             "emoji": "⚫"
                           },
                            {
                             "keywords": ["shape", "error", "danger"],
                             "emoji": "🔴"
                           },
                           {
                             "keywords": ["shape", "icon", "button"],
                             "emoji": "🔵"
                           },
                           {
                             "keywords": ["shape", "jewel", "gem"],
                             "emoji": "🔸"
                           },
                           {
                             "keywords": ["shape", "jewel", "gem"],
                             "emoji": "🔹"
                           },
                            {
                             "keywords": ["shape", "jewel", "gem"],
                             "emoji": "🔶"
                           },
                           {
                             "keywords": ["shape", "jewel", "gem"],
                             "emoji": "🔷"
                           },
                           {
                             "keywords": ["shape", "direction", "up", "top"],
                             "emoji": "🔺"
                           },
                           {
                             "keywords": ["shape", "icon"],
                             "emoji": "▪️"
                           },
                           {
                             "keywords": ["shape", "icon"],
                             "emoji": "▫️"
                           },
                           {
                             "keywords": ["shape", "icon", "button"],
                             "emoji": "⬛"
                           },
                           {
                             "keywords": ["shape", "icon", "stone", "button"],
                             "emoji": "⬜"
                           },
                           {
                             "keywords": ["shape", "direction", "bottom"],
                             "emoji": "🔻"
                           },
                           {
                             "keywords": ["shape", "button", "icon"],
                             "emoji": "◼️"
                           },
                           {
                             "keywords": ["shape", "stone", "icon"],
                             "emoji": "◻️"
                           },
                           {
                             "keywords": ["icon", "shape", "button"],
                             "emoji": "◾"
                           },
                           {
                             "keywords": ["shape", "stone", "icon", "button"],
                             "emoji": "◽"
                           },
                           {
                             "keywords": ["shape", "input", "frame"],
                             "emoji": "🔲"
                           },
                           {
                             "keywords": ["shape", "input"],
                             "emoji": "🔳"
                           },
                           {
                             "keywords": ["sound", "volume", "silence", "broadcast"],
                             "emoji": "🔈"
                           },
                           {
                             "keywords": ["volume", "speaker", "broadcast"],
                             "emoji": "🔉"
                           },
                           {
                             "keywords": ["volume", "noise", "noisy", "speaker", "broadcast"],
                             "emoji": "🔊"
                           },
                           {
                             "keywords": ["sound", "volume", "silence", "quiet"],
                             "emoji": "🔇"
                           },
                           {
                             "keywords": ["sound", "speaker", "volume"],
                             "emoji": "📣"
                           },
                           {
                             "keywords": ["volume", "sound"],
                             "emoji": "📢"
                           },
                           {
                             "keywords": ["sound", "notification", "christmas", "xmas", "chime"],
                             "emoji": "🔔"
                           },
                           {
                             "keywords": ["sound", "volume", "mute", "quiet", "silent"],
                             "emoji": "🔕"
                           },
                           {
                             "keywords": ["poker", "cards", "game", "play", "magic"],
                             "emoji": "🃏"
                           },
                           {
                             "keywords": ["game", "play", "chinese", "kanji"],
                             "emoji": "🀄"
                           },
                           {
                             "keywords": ["poker", "cards", "suits", "magic"],
                             "emoji": "♠️"
                           },
                           {
                             "keywords": ["poker", "cards", "magic", "suits"],
                             "emoji": "♣️"
                           },
                           {
                             "keywords": ["poker", "cards", "magic", "suits"],
                             "emoji": "♥️"
                           },
                           {
                             "keywords": ["poker", "cards", "magic", "suits"],
                             "emoji": "♦️"
                           },
                           {
                             "keywords": ["game", "sunset", "red"],
                             "emoji": "🎴"
                           },
                           {
                             "keywords": ["bubble", "cloud", "speech", "thinking", "dream"],
                             "emoji": "💭"
                           },
                           {
                             "keywords": ["caption", "speech", "thinking", "mad"],
                             "emoji": "🗯"
                           },
                           {
                             "keywords": ["bubble", "words", "message", "talk", "chatting"],
                             "emoji": "💬"
                           },
                           {
                             "keywords": ["words", "message", "talk", "chatting"],
                             "emoji": "🗨"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕐"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕑"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕒"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕓"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕔"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule", "dawn", "dusk"],
                             "emoji": "🕕"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕖"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕗"
                           },
                            {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕘"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕙"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕚"
                           },
                           {
                             "keywords": [
                               "time",
                               "noon",
                               "midnight",
                               "midday",
                               "late",
                               "early",
                               "schedule"
                             ],
                             "emoji": "🕛"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕜"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕝"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕞"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕟"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕠"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕡"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕢"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕣"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕤"
                           },
                            {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕥"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕦"
                           },
                           {
                             "keywords": ["time", "late", "early", "schedule"],
                             "emoji": "🕧"
                           }
                         ]
                       },
      
    
            {
              "id": "flags",
              "name": "Flags",
              "symbol": "messages-emoji-keyboard-flags",
              "emojis": [
                 {
                  "keywords": ["af", "flag", "nation", "country", "banner", "afghanistan"],
                  "emoji": "🇦🇫"
                },
                 {
                  "keywords": ["Åland", "islands", "flag", "nation", "country", "banner", "aland_islands"],
                  "emoji": "🇦🇽"
                },
                 {
                  "keywords": ["al", "flag", "nation", "country", "banner", "albania"],
                  "emoji": "🇦🇱"
                },
                 {
                  "keywords": ["dz", "flag", "nation", "country", "banner", "algeria"],
                  "emoji": "🇩🇿"
                },
                 {
                  "keywords": ["american", "ws", "flag", "nation", "country", "banner", "american_samoa"],
                  "emoji": "🇦🇸"
                },
                 {
                  "keywords": ["ad", "flag", "nation", "country", "banner", "andorra"],
                  "emoji": "🇦🇩"
                },
                 {
                  "keywords": ["ao", "flag", "nation", "country", "banner", "angola"],
                  "emoji": "🇦🇴"
                },
                 {
                  "keywords": ["ai", "flag", "nation", "country", "banner", "anguilla"],
                  "emoji": "🇦🇮"
                },
                 {
                  "keywords": ["aq", "flag", "nation", "country", "banner", "antarctica"],
                  "emoji": "🇦🇶"
                },
                {
                  "keywords": [
                    "antigua",
                    "barbuda",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "antigua_barbuda"
                  ],
                  "emoji": "🇦🇬"
                },
                 {
                  "keywords": ["ar", "flag", "nation", "country", "banner", "argentina"],
                  "emoji": "🇦🇷"
                },
                 {
                  "keywords": ["am", "flag", "nation", "country", "banner", "armenia"],
                  "emoji": "🇦🇲"
                },
                 {
                  "keywords": ["aw", "flag", "nation", "country", "banner", "aruba"],
                  "emoji": "🇦🇼"
                },
                 {
                  "keywords": ["au", "flag", "nation", "country", "banner", "australia"],
                  "emoji": "🇦🇺"
                },
                 {
                  "keywords": ["at", "flag", "nation", "country", "banner", "austria"],
                  "emoji": "🇦🇹"
                },
                 {
                  "keywords": ["az", "flag", "nation", "country", "banner", "azerbaijan"],
                  "emoji": "🇦🇿"
                },
                 {
                  "keywords": ["bs", "flag", "nation", "country", "banner", "bahamas"],
                  "emoji": "🇧🇸"
                },
                 {
                  "keywords": ["bh", "flag", "nation", "country", "banner", "bahrain"],
                  "emoji": "🇧🇭"
                },
                 {
                  "keywords": ["bd", "flag", "nation", "country", "banner", "bangladesh"],
                  "emoji": "🇧🇩"
                },
                 {
                  "keywords": ["bb", "flag", "nation", "country", "banner", "barbados"],
                  "emoji": "🇧🇧"
                },
                 {
                  "keywords": ["by", "flag", "nation", "country", "banner", "belarus"],
                  "emoji": "🇧🇾"
                },
                 {
                  "keywords": ["be", "flag", "nation", "country", "banner", "belgium"],
                  "emoji": "🇧🇪"
                },
                 {
                  "keywords": ["bz", "flag", "nation", "country", "banner", "belize"],
                  "emoji": "🇧🇿"
                },
                 {
                  "keywords": ["bj", "flag", "nation", "country", "banner", "benin"],
                  "emoji": "🇧🇯"
                },
                 {
                  "keywords": ["bm", "flag", "nation", "country", "banner", "bermuda"],
                  "emoji": "🇧🇲"
                },
                 {
                  "keywords": ["bt", "flag", "nation", "country", "banner", "bhutan"],
                  "emoji": "🇧🇹"
                },
                 {
                  "keywords": ["bo", "flag", "nation", "country", "banner", "bolivia"],
                  "emoji": "🇧🇴"
                },
                 {
                  "keywords": ["bonaire", "flag", "nation", "country", "banner", "caribbean_netherlands"],
                  "emoji": "🇧🇶"
                },
                {
                  "keywords": [
                    "bosnia",
                    "herzegovina",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "bosnia_herzegovina"
                  ],
                  "emoji": "🇧🇦"
                },
                 {
                  "keywords": ["bw", "flag", "nation", "country", "banner", "botswana"],
                  "emoji": "🇧🇼"
                },
                 {
                  "keywords": ["br", "flag", "nation", "country", "banner", "brazil"],
                  "emoji": "🇧🇷"
                },
                 {
                  "keywords": [
                    "british",
                    "indian",
                    "ocean",
                    "territory",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "british_indian_ocean_territory"
                  ],
                  "emoji": "🇮🇴"
                },
                 {
                  "keywords": [
                    "british",
                    "virgin",
                    "islands",
                    "bvi",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "british_virgin_islands"
                  ],
                  "emoji": "🇻🇬"
                },
                 {
                  "keywords": ["bn", "darussalam", "flag", "nation", "country", "banner", "brunei"],
                  "emoji": "🇧🇳"
                },
                 {
                  "keywords": ["bg", "flag", "nation", "country", "banner", "bulgaria"],
                  "emoji": "🇧🇬"
                },
                 {
                  "keywords": ["burkina", "faso", "flag", "nation", "country", "banner", "burkina_faso"],
                  "emoji": "🇧🇫"
                },
                {
                  "keywords": ["bi", "flag", "nation", "country", "banner", "burundi"],
                  "emoji": "🇧🇮"
                },
                 {
                  "keywords": ["cabo", "verde", "flag", "nation", "country", "banner", "cape_verde"],
                  "emoji": "🇨🇻"
                },
                 {
                  "keywords": ["kh", "flag", "nation", "country", "banner", "cambodia"],
                  "emoji": "🇰🇭"
                },
                 {
                  "keywords": ["cm", "flag", "nation", "country", "banner", "cameroon"],
                  "emoji": "🇨🇲"
                },
                 {
                  "keywords": ["ca", "flag", "nation", "country", "banner", "canada"],
                  "emoji": "🇨🇦"
                },
                 {
                  "keywords": [
                    "canary",
                    "islands",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "canary_islands"
                  ],
                  "emoji": "🇮🇨"
                },
                 {
                  "keywords": [
                    "cayman",
                    "islands",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "cayman_islands"
                  ],
                  "emoji": "🇰🇾"
                },
                 {
                  "keywords": [
                    "central",
                    "african",
                    "republic",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "central_african_republic"
                  ],
                  "emoji": "🇨🇫"
                },
                 {
                  "keywords": ["td", "flag", "nation", "country", "banner", "chad"],
                  "emoji": "🇹🇩"
                },
                 {
                  "keywords": ["flag", "nation", "country", "banner", "chile"],
                  "emoji": "🇨🇱"
                },
                 {
                  "keywords": [
                    "china",
                    "chinese",
                    "prc",
                    "flag",
                    "country",
                    "nation",
                    "banner",
                    "cn"
                  ],
                  "emoji": "🇨🇳"
                },
                 {
                  "keywords": [
                    "christmas",
                    "island",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "christmas_island"
                  ],
                  "emoji": "🇨🇽"
                },
                 {
                  "keywords": [
                    "cocos",
                    "keeling",
                    "islands",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "cocos_islands"
                  ],
                  "emoji": "🇨🇨"
                },
                 {
                  "keywords": ["co", "flag", "nation", "country", "banner", "colombia"],
                  "emoji": "🇨🇴"
                },
                 {
                  "keywords": ["km", "flag", "nation", "country", "banner", "comoros"],
                  "emoji": "🇰🇲"
                },
                 {
                  "keywords": ["congo", "flag", "nation", "country", "banner", "congo_brazzaville"],
                  "emoji": "🇨🇬"
                },
                 {
                  "keywords": [
                    "congo",
                    "democratic",
                    "republic",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "congo_kinshasa"
                  ],
                  "emoji": "🇨🇩"
                },
                {
                  "keywords": ["cook", "islands", "flag", "nation", "country", "banner", "cook_islands"],
                  "emoji": "🇨🇰"
                },
                 {
                  "keywords": ["costa", "rica", "flag", "nation", "country", "banner", "costa_rica"],
                  "emoji": "🇨🇷"
                },
                 {
                  "keywords": ["hr", "flag", "nation", "country", "banner", "croatia"],
                  "emoji": "🇭🇷"
                },
                 {
                  "keywords": ["cu", "flag", "nation", "country", "banner", "cuba"],
                  "emoji": "🇨🇺"
                },
                 {
                  "keywords": ["curaçao", "flag", "nation", "country", "banner", "curacao"],
                  "emoji": "🇨🇼"
                },
                 {
                  "keywords": ["cy", "flag", "nation", "country", "banner", "cyprus"],
                  "emoji": "🇨🇾"
                },
                {
                  "keywords": ["cz", "flag", "nation", "country", "banner", "czech_republic"],
                  "emoji": "🇨🇿"
                },
                {
                  "keywords": ["dk", "flag", "nation", "country", "banner", "denmark"],
                  "emoji": "🇩🇰"
                },
                {
                  "keywords": ["dj", "flag", "nation", "country", "banner", "djibouti"],
                  "emoji": "🇩🇯"
                },
                 {
                  "keywords": ["dm", "flag", "nation", "country", "banner", "dominica"],
                  "emoji": "🇩🇲"
                },
                 {
                  "keywords": [
                    "dominican",
                    "republic",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "dominican_republic"
                  ],
                  "emoji": "🇩🇴"
                },
                {
                  "keywords": ["ec", "flag", "nation", "country", "banner", "ecuador"],
                  "emoji": "🇪🇨"
                },
                 {
                  "keywords": ["eg", "flag", "nation", "country", "banner", "egypt"],
                  "emoji": "🇪🇬"
                },
                 {
                  "keywords": ["el", "salvador", "flag", "nation", "country", "banner", "el_salvador"],
                  "emoji": "🇸🇻"
                },
                 {
                  "keywords": ["equatorial", "gn", "flag", "nation", "country", "banner", "equatorial_guinea"],
                  "emoji": "🇬🇶"
                },
                 {
                  "keywords": ["er", "flag", "nation", "country", "banner", "eritrea"],
                  "emoji": "🇪🇷"
                },
                 {
                  "keywords": ["ee", "flag", "nation", "country", "banner", "estonia"],
                  "emoji": "🇪🇪"
                },
                 {
                  "keywords": ["et", "flag", "nation", "country", "banner", "ethiopia"],
                  "emoji": "🇪🇹"
                },
                 {
                  "keywords": ["european", "union", "flag", "banner", "eu"],
                  "emoji": "🇪🇺"
                },
                 {
                  "keywords": [
                    "falkland",
                    "islands",
                    "malvinas",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "falkland_islands"
                  ],
                  "emoji": "🇫🇰"
                },
                 {
                  "keywords": ["faroe", "islands", "flag", "nation", "country", "banner", "faroe_islands"],
                  "emoji": "🇫🇴"
                },
                 {
                  "keywords": ["fj", "flag", "nation", "country", "banner", "fiji"],
                  "emoji": "🇫🇯"
                },
                 {
                  "keywords": ["fi", "flag", "nation", "country", "banner", "finland"],
                  "emoji": "🇫🇮"
                },
                 {
                  "keywords": ["banner", "flag", "nation", "france", "french", "country", "fr"],
                  "emoji": "🇫🇷"
                },
                {
                  "keywords": ["french", "guiana", "flag", "nation", "country", "banner", "french_guiana"],
                  "emoji": "🇬🇫"
                },
                 {
                  "keywords": [
                    "french",
                    "polynesia",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "french_polynesia"
                  ],
                  "emoji": "🇵🇫"
                },
                 {
                  "keywords": [
                    "french",
                    "southern",
                    "territories",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "french_southern_territories"
                  ],
                  "emoji": "🇹🇫"
                },
                 {
                  "keywords": ["ga", "flag", "nation", "country", "banner", "gabon"],
                  "emoji": "🇬🇦"
                },
                 {
                  "keywords": ["gm", "flag", "nation", "country", "banner", "gambia"],
                  "emoji": "🇬🇲"
                },
                 {
                  "keywords": ["ge", "flag", "nation", "country", "banner", "georgia"],
                  "emoji": "🇬🇪"
                },
                 {
                  "keywords": ["german", "nation", "flag", "country", "banner", "de"],
                  "emoji": "🇩🇪"
                },
                 {
                  "keywords": ["gh", "flag", "nation", "country", "banner", "ghana"],
                  "emoji": "🇬🇭"
                },
                 {
                  "keywords": ["gi", "flag", "nation", "country", "banner", "gibraltar"],
                  "emoji": "🇬🇮"
                },
                 {
                  "keywords": ["gr", "flag", "nation", "country", "banner", "greece"],
                  "emoji": "🇬🇷"
                },
                 {
                  "keywords": ["gl", "flag", "nation", "country", "banner", "greenland"],
                  "emoji": "🇬🇱"
                },
                 {
                  "keywords": ["gd", "flag", "nation", "country", "banner", "grenada"],
                  "emoji": "🇬🇩"
                },
                 {
                  "keywords": ["gp", "flag", "nation", "country", "banner", "guadeloupe"],
                  "emoji": "🇬🇵"
                },
                 {
                  "keywords": ["gu", "flag", "nation", "country", "banner", "guam"],
                  "emoji": "🇬🇺"
                },
                 {
                  "keywords": ["gt", "flag", "nation", "country", "banner", "guatemala"],
                  "emoji": "🇬🇹"
                },
                 {
                  "keywords": ["gg", "flag", "nation", "country", "banner", "guernsey"],
                  "emoji": "🇬🇬"
                },
                 {
                  "keywords": ["gn", "flag", "nation", "country", "banner", "guinea"],
                  "emoji": "🇬🇳"
                },
                {
                  "keywords": ["gw", "bissau", "flag", "nation", "country", "banner", "guinea_bissau"],
                  "emoji": "🇬🇼"
                },
                 {
                  "keywords": ["gy", "flag", "nation", "country", "banner", "guyana"],
                  "emoji": "🇬🇾"
                },
                 {
                  "keywords": ["ht", "flag", "nation", "country", "banner", "haiti"],
                  "emoji": "🇭🇹"
                },
                 {
                  "keywords": ["hn", "flag", "nation", "country", "banner", "honduras"],
                  "emoji": "🇭🇳"
                },
                 {
                  "keywords": ["hong", "kong", "flag", "nation", "country", "banner", "hong_kong"],
                  "emoji": "🇭🇰"
                },
                 {
                  "keywords": ["hu", "flag", "nation", "country", "banner", "hungary"],
                  "emoji": "🇭🇺"
                },
                 {
                  "keywords": ["is", "flag", "nation", "country", "banner", "iceland"],
                  "emoji": "🇮🇸"
                },
                {
                  "keywords": ["in", "flag", "nation", "country", "banner", "india"],
                  "emoji": "🇮🇳"
                },
                 {
                  "keywords": ["flag", "nation", "country", "banner", "indonesia"],
                  "emoji": "🇮🇩"
                },
                 {
                  "keywords": [
                    "iran,",
                    "islamic",
                    "republic",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                     "iran"
                  ],
                  "emoji": "🇮🇷"
                },
                 {
                  "keywords": ["iq", "flag", "nation", "country", "banner", "iraq"],
                  "emoji": "🇮🇶"
                },
                 {
                  "keywords": ["ie", "flag", "nation", "country", "banner", "ireland"],
                  "emoji": "🇮🇪"
                },
                 {
                  "keywords": ["isle", "man", "flag", "nation", "country", "banner", "isle_of_man"],
                  "emoji": "🇮🇲"
                },
                 {
                  "keywords": ["il", "flag", "nation", "country", "banner", "israel"],
                  "emoji": "🇮🇱"
                },
                 {
                  "keywords": ["italy", "flag", "nation", "country", "banner","it"],
                  "emoji": "🇮🇹"
                },
                 {
                  "keywords": ["ivory", "coast", "flag", "nation", "country", "banner", "cote_divoire"],
                  "emoji": "🇨🇮"
                },
                {
                  "keywords": ["jm", "flag", "nation", "country", "banner", "jamaica"],
                  "emoji": "🇯🇲"
                },
                {
                  "keywords": ["japanese", "nation", "flag", "country", "banner", "jp"],
                  "emoji": "🇯🇵"
                },
                 {
                  "keywords": ["je", "flag", "nation", "country", "banner", "jersey"],
                  "emoji": "🇯🇪"
                },
                 {
                  "keywords": ["jo", "flag", "nation", "country", "banner", "jordan"],
                  "emoji": "🇯🇴"
                },
                 {
                  "keywords": ["kz", "flag", "nation", "country", "banner", "kazakhstan"],
                  "emoji": "🇰🇿"
                },
                {
                  "keywords": ["ke", "flag", "nation", "country", "banner", "kenya"],
                  "emoji": "🇰🇪"
                },
                 {
                  "keywords": ["ki", "flag", "nation", "country", "banner", "kiribati"],
                  "emoji": "🇰🇮"
                },
                 {
                  "keywords": ["xk", "flag", "nation", "country", "banner", "kosovo"],
                  "emoji": "🇽🇰"
                },
                 {
                  "keywords": ["kw", "flag", "nation", "country", "banner", "kuwait"],
                  "emoji": "🇰🇼"
                },
                 {
                  "keywords": ["kg", "flag", "nation", "country", "banner", "kyrgyzstan"],
                  "emoji": "🇰🇬"
                },
                 {
                  "keywords": [
                    "lao",
                    "democratic",
                    "republic",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "laos"
                  ],
                  "emoji": "🇱🇦"
                },
                 {
                  "keywords": ["lv", "flag", "nation", "country", "banner", "latvia"],
                  "emoji": "🇱🇻"
                },
                 {
                  "keywords": ["lb", "flag", "nation", "country", "banner", "lebanon"],
                  "emoji": "🇱🇧"
                },
                 {
                  "keywords": ["ls", "flag", "nation", "country", "banner", "lesotho"],
                  "emoji": "🇱🇸"
                },
                 {
                  "keywords": ["lr", "flag", "nation", "country", "banner", "liberia"],
                  "emoji": "🇱🇷"
                },
                {
                  "keywords": ["ly", "flag", "nation", "country", "banner", "libya"],
                  "emoji": "🇱🇾"
                },
                 {
                  "keywords": ["li", "flag", "nation", "country", "banner", "liechtenstein"],
                  "emoji": "🇱🇮"
                },
                 {
                  "keywords": ["lt", "flag", "nation", "country", "banner", "lithuania"],
                  "emoji": "🇱🇹"
                },
                 {
                  "keywords": ["lu", "flag", "nation", "country", "banner", "luxembourg"],
                  "emoji": "🇱🇺"
                },
                {
                  "keywords": ["macao", "flag", "nation", "country", "banner", "macau"],
                  "emoji": "🇲🇴"
                },
                {
                  "keywords": ["macedonia", "flag", "nation", "country", "banner", "macedonia"],
                  "emoji": "🇲🇰"
                },
                 {
                  "keywords": ["mg", "flag", "nation", "country", "banner", "madagascar"],
                  "emoji": "🇲🇬"
                },
                 {
                  "keywords": ["mw", "flag", "nation", "country", "banner", "malawi"],
                  "emoji": "🇲🇼"
                },
                 {
                  "keywords": ["my", "flag", "nation", "country", "banner", "malaysia"],
                  "emoji": "🇲🇾"
                },
                 {
                  "keywords": ["mv", "flag", "nation", "country", "banner", "maldives"],
                  "emoji": "🇲🇻"
                },
                 {
                  "keywords": ["ml", "flag", "nation", "country", "banner", "mali"],
                  "emoji": "🇲🇱"
                },
                 {
                  "keywords": ["mt", "flag", "nation", "country", "banner", "malta"],
                  "emoji": "🇲🇹"
                },
                {
                  "keywords": [
                    "marshall",
                    "islands",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "marshall_islands"
                  ],
                  "emoji": "🇲🇭"
                },
                 {
                  "keywords": ["mq", "flag", "nation", "country", "banner", "martinique"],
                  "emoji": "🇲🇶"
                },
                 {
                  "keywords": ["mr", "flag", "nation", "country", "banner", "mauritania"],
                  "emoji": "🇲🇷"
                },
                 {
                  "keywords": ["mu", "flag", "nation", "country", "banner", "mauritius"],
                  "emoji": "🇲🇺"
                },
                 {
                  "keywords": ["yt", "flag", "nation", "country", "banner", "mayotte"],
                  "emoji": "🇾🇹"
                },
                 {
                  "keywords": ["mx", "flag", "nation", "country", "banner", "mexico"],
                  "emoji": "🇲🇽"
                },
                {
                  "keywords": [
                    "micronesia",
                    "federated",
                    "states",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "micronesia"
                  ],
                  "emoji": "🇫🇲"
                },
                 {
                  "keywords": [
                    "moldova",
                    "republic",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "moldova"
                  ],
                  "emoji": "🇲🇩"
                },
                 {
                  "keywords": ["mc", "flag", "nation", "country", "banner", "monaco"],
                  "emoji": "🇲🇨"
                },
                 {
                  "keywords": ["mn", "flag", "nation", "country", "banner", "mongolia"],
                  "emoji": "🇲🇳"
                },
                 {
                  "keywords": ["me", "flag", "nation", "country", "banner", "montenegro"],
                  "emoji": "🇲🇪"
                },
                 {
                  "keywords": ["ms", "flag", "nation", "country", "banner", "montserrat"],
                  "emoji": "🇲🇸"
                },
                 {
                  "keywords": ["ma", "flag", "nation", "country", "banner", "morocco"],
                  "emoji": "🇲🇦"
                },
                 {
                  "keywords": ["mz", "flag", "nation", "country", "banner", "mozambique"],
                  "emoji": "🇲🇿"
                },
                 {
                  "keywords": ["mm", "flag", "nation", "country", "banner", "myanmar"],
                  "emoji": "🇲🇲"
                },
                {
                  "keywords": ["na", "flag", "nation", "country", "banner", "namibia"],
                  "emoji": "🇳🇦"
                },
                 {
                  "keywords": ["nr", "flag", "nation", "country", "banner", "nauru"],
                  "emoji": "🇳🇷"
                },
                {
                  "keywords": ["np", "flag", "nation", "country", "banner", "nepal"],
                  "emoji": "🇳🇵"
                },
                 {
                  "keywords": ["nl", "flag", "nation", "country", "banner", "netherlands"],
                  "emoji": "🇳🇱"
                },
                 {
                  "keywords": ["new", "caledonia", "flag", "nation", "country", "banner", "new_caledonia"],
                  "emoji": "🇳🇨"
                },
                 {
                  "keywords": ["new", "zealand", "flag", "nation", "country", "banner", "new_zealand"],
                  "emoji": "🇳🇿"
                },
                {
                  "keywords": ["ni", "flag", "nation", "country", "banner", "nicaragua"],
                  "emoji": "🇳🇮"
                },
                 {
                  "keywords": ["ne", "flag", "nation", "country", "banner", "niger"],
                  "emoji": "🇳🇪"
                },
                 {
                  "keywords": ["flag", "nation", "country", "banner", "nigeria"],
                  "emoji": "🇳🇬"
                },
                {
                  "keywords": ["nu", "flag", "nation", "country", "banner", "niue"],
                  "emoji": "🇳🇺"
                },
                 {
                  "keywords": [
                    "norfolk",
                    "island",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "norfolk_island"
                  ],
                  "emoji": "🇳🇫"
                },
                 {
                  "keywords": [
                    "northern",
                    "mariana",
                    "islands",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "northern_mariana_islands"
                  ],
                  "emoji": "🇲🇵"
                },
                 {
                  "keywords": ["north", "korea", "nation", "flag", "country", "banner", "north_korea"],
                  "emoji": "🇰🇵"
                },
                {
                  "keywords": ["no", "flag", "nation", "country", "banner", "norway"],
                  "emoji": "🇳🇴"
                },
                 {
                  "keywords": ["om_symbol", "flag", "nation", "country", "banner", "oman"],
                  "emoji": "🇴🇲"
                },
                 {
                  "keywords": ["pk", "flag", "nation", "country", "banner", "pakistan"],
                  "emoji": "🇵🇰"
                },
                {
                  "keywords": ["pw", "flag", "nation", "country", "banner", "palau"],
                  "emoji": "🇵🇼"
                },
                 {
                  "keywords": [
                    "palestine",
                    "palestinian",
                    "territories",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "palestinian_territories"
                  ],
                  "emoji": "🇵🇸"
                },
                 {
                  "keywords": ["pa", "flag", "nation", "country", "banner", "panama"],
                  "emoji": "🇵🇦"
                },
                 {
                  "keywords": [
                    "papua",
                    "new",
                    "guinea",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "papua_new_guinea"
                  ],
                  "emoji": "🇵🇬"
                },
                 {
                  "keywords": ["py", "flag", "nation", "country", "banner", "paraguay"],
                  "emoji": "🇵🇾"
                },
                 {
                  "keywords": ["pe", "flag", "nation", "country", "banner", "peru"],
                  "emoji": "🇵🇪"
                },
                 {
                  "keywords": ["ph", "flag", "nation", "country", "banner", "philippines"],
                  "emoji": "🇵🇭"
                },
                {
                  "keywords": ["pitcairn", "flag", "nation", "country", "banner", "pitcairn_islands"],
                  "emoji": "🇵🇳"
                },
                 {
                  "keywords": ["pl", "flag", "nation", "country", "banner", "poland"],
                  "emoji": "🇵🇱"
                },
                 {
                  "keywords": ["pt", "flag", "nation", "country", "banner", "portugal"],
                  "emoji": "🇵🇹"
                },
                {
                  "keywords": ["puerto", "rico", "flag", "nation", "country", "banner", "puerto_rico"],
                  "emoji": "🇵🇷"
                },
                 {
                  "keywords": ["qa", "flag", "nation", "country", "banner", "qatar"],
                  "emoji": "🇶🇦"
                },
                {
                  "keywords": ["réunion", "flag", "nation", "country", "banner", "reunion"],
                  "emoji": "🇷🇪"
                },
                 {
                  "keywords": ["ro", "flag", "nation", "country", "banner", "romania"],
                  "emoji": "🇷🇴"
                },
                 {
                  "keywords": [
                    "russian",
                    "federation",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "ru"
                  ],
                  "emoji": "🇷🇺"
                },
                {
                  "keywords": ["rw", "flag", "nation", "country", "banner", "rwanda"],
                  "emoji": "🇷🇼"
                },
                 {
                  "keywords": [
                    "saint",
                    "barthélemy",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "st_barthelemy"
                  ],
                  "emoji": "🇧🇱"
                },
                 {
                  "keywords": [
                    "saint",
                    "helena",
                    "ascension",
                    "tristan",
                    "cunha",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "st_helena"
                  ],
                  "emoji": "🇸🇭"
                },
                 {
                  "keywords": [
                    "saint",
                    "kitts",
                    "nevis",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "st_kitts_nevis"
                  ],
                  "emoji": "🇰🇳"
                },
                 {
                  "keywords": ["saint", "lucia", "flag", "nation", "country", "banner", "st_lucia"],
                  "emoji": "🇱🇨",
                },
                 {
                  "keywords": [
                    "saint",
                    "pierre",
                    "miquelon",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "st_pierre_miquelon"
                  ],
                  "emoji": "🇵🇲"
                },
                 {
                  "keywords": [
                    "saint",
                    "vincent",
                    "grenadines",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "st_vincent_grenadines"
                  ],
                  "emoji": "🇻🇨"
                },
                 {
                  "keywords": ["ws", "flag", "nation", "country", "banner", "samoa"],
                  "emoji": "🇼🇸"
                },
                 {
                  "keywords": ["san", "marino", "flag", "nation", "country", "banner", "san_marino"],
                  "emoji": "🇸🇲"
                },
                 {
                  "keywords": [
                    "sao",
                    "tome",
                    "principe",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "sao_tome_principe"
                  ],
                  "emoji": "🇸🇹"
                },
                 {
                  "keywords": ["flag", "nation", "country", "banner", "saudi_arabia"],
                  "emoji": "🇸🇦"
                },
                 {
                  "keywords": ["sn", "flag", "nation", "country", "banner", "senegal"],
                  "emoji": "🇸🇳"
                },
                {
                  "keywords": ["rs", "flag", "nation", "country", "banner", "serbia"],
                  "emoji": "🇷🇸"
                },
                 {
                  "keywords": ["sc", "flag", "nation", "country", "banner", "seychelles"],
                  "emoji": "🇸🇨"
                },
                 {
                  "keywords": ["sierra", "leone", "flag", "nation", "country", "banner", "sierra_leone"],
                  "emoji": "🇸🇱"
                },
                {
                  "keywords": ["sg", "flag", "nation", "country", "banner", "singapore"],
                  "emoji": "🇸🇬"
                },
                {
                  "keywords": [
                    "sint",
                    "maarten",
                    "dutch",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "sint_maarten"
                  ],
                  "emoji": "🇸🇽"
                },
                 {
                  "keywords": ["sk", "flag", "nation", "country", "banner", "slovakia"],
                  "emoji": "🇸🇰"
                },
                 {
                  "keywords": ["si", "flag", "nation", "country", "banner", "slovenia"],
                  "emoji": "🇸🇮"
                },
                 {
                  "keywords": [
                    "solomon",
                    "islands",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "solomon_islands"
                  ],
                  "emoji": "🇸🇧"
                },
                 {
                  "keywords": ["so", "flag", "nation", "country", "banner", "somalia"],
                  "emoji": "🇸🇴"
                },
                 {
                  "keywords": ["south", "africa", "flag", "nation", "country", "banner", "south_africa"],
                  "emoji": "🇿🇦"
                },
                 {
                  "keywords": [
                    "south",
                    "georgia",
                    "sandwich",
                    "islands",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "south_georgia_south_sandwich_islands"
                  ],
                  "emoji": "🇬🇸"
                },
                {
                  "keywords": ["south", "korea", "nation", "flag", "country", "banner", "kr"],
                  "emoji": "🇰🇷"
                },
                 {
                  "keywords": ["south", "sd", "flag", "nation", "country", "banner", "south_sudan"],
                  "emoji": "🇸🇸"
                },
                {
                  "keywords": ["spain", "flag", "nation", "country", "banner", "es"],
                  "emoji": "🇪🇸"
                },
                 {
                  "keywords": ["sri", "lanka", "flag", "nation", "country", "banner", "sri_lanka"],
                  "emoji": "🇱🇰"
                },
                {
                  "keywords": ["sd", "flag", "nation", "country", "banner", "sudan"],
                  "emoji": "🇸🇩"
                },
                 {
                  "keywords": ["sr", "flag", "nation", "country", "banner", "suriname"],
                  "emoji": "🇸🇷"
                },
                 {
                  "keywords": ["sz", "flag", "nation", "country", "banner", "swaziland"],
                  "emoji": "🇸🇿"
                },
                 {
                  "keywords": ["se", "flag", "nation", "country", "banner", "sweden"],
                  "emoji": "🇸🇪"
                },
                {
                  "keywords": ["ch", "flag", "nation", "country", "banner", "switzerland"],
                  "emoji": "🇨🇭"
                },
                {
                  "keywords": ["syrian", "arab", "republic",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                    "syria"
                  ],
                  "emoji": "🇸🇾"
                },
                {
                  "keywords": ["tw", "flag", "nation", "country", "banner", "taiwan"],
                  "emoji": "🇹🇼"
                },
                {
                  "keywords": ["tj", "flag", "nation", "country", "banner", "tajikistan"],
                  "emoji": "🇹🇯"
                },
                 {
                  "keywords": ["tanzania", "united", "republic", "flag", "nation", "country", "banner"],
                  "emoji": "🇹🇿"
                },
                 {
                  "keywords": ["th", "flag", "nation", "country", "banner", "thailand"],
                  "emoji": "🇹🇭"
                },
                {
                  "keywords": ["timor", "leste", "flag", "nation", "country", "banner", "timor_leste"],
                  "emoji": "🇹🇱"
                },
                 {
                  "keywords": ["tg", "flag", "nation", "country", "banner", "togo"],
                  "emoji": "🇹🇬"
                },
                 {
                  "keywords": ["tk", "flag", "nation", "country", "banner", "tokelau"],
                  "emoji": "🇹🇰"
                },
                {
                  "keywords": ["to", "flag", "nation", "country", "banner", "tonga"],
                  "emoji": "🇹🇴"
                },
                {
                  "keywords": [
                    "trinidad",
                    "tobago",
                    "flag",
                    "nation",
                    "country",
                    "banner",
        "trinidad_tobago"
                  ],
                  "emoji": "🇹🇹"
                },
                {
                  "keywords": ["tn", "flag", "nation", "country", "banner", "tunisia"],
                  "emoji": "🇹🇳"
                },
                {
                  "keywords": ["turkey", "flag", "nation", "country", "banner", "tr"],
                  "emoji": "🇹🇷"
                },
                {
                  "keywords": ["flag", "nation", "country", "banner", "turkmenistan"],
                  "emoji": "🇹🇲"
                },
                {
                  "keywords": [
                    "turks",
                    "caicos",
                    "islands",
                    "flag",
                    "nation",
                    "country",
                    "banner",
                      "turks_caicos_islands"
                  ],
                  "emoji": "🇹🇨"
                },
                {
                  "keywords": ["flag", "nation", "country", "banner", "tuvalu"],
                  "emoji": "🇹🇻"
                },
                {
                  "keywords": ["ug", "flag", "nation", "country", "banner", "uganda"],
                  "emoji": "🇺🇬"
                },
                {
                  "keywords": ["ua", "flag", "nation", "country", "banner", "ukraine"],
                  "emoji": "🇺🇦"
                },
                {
                  "keywords": ["united", "arab", "emirates", "flag", "nation", "country", "banner", "united", "arab", "emirates"],
                  "emoji": "🇦🇪"
                },
                {
                  "keywords": ["united", "kingdom", "great", "britain", "northern", "ireland", "flag", "nation", "country", "banner", "british", "UK", "english", "england", "union jack", "uk"],
                  "emoji": "🇬🇧"
                },
                {
                  "keywords": ["flag", "english", "england"],
                  "emoji": "🏴󠁧󠁢󠁥󠁮󠁧󠁿"
                },
                {
                  "keywords": ["flag", "scottish", "scotland"],
                  "emoji": "🏴󠁧󠁢󠁳󠁣󠁴󠁿"
                },
                {
                  "keywords": ["flag", "welsh", "wales"],
                  "emoji": "🏴󠁧󠁢󠁷󠁬󠁳󠁿"
                },
                {
                  "keywords": ["united", "states", "america", "flag", "nation", "country", "banner", "us"],
                  "emoji": "🇺🇸"
                },
                {
                  "keywords": ["virgin", "islands", "us", "flag", "nation", "country", "banner", "us", "virgin", "islands"],
                  "emoji": "🇻🇮"
                },
                 {
                  "keywords": ["uy", "flag", "nation", "country", "banner", "uruguay"],
                  "emoji": "🇺🇾"
                },
                {
                  "keywords": ["uz", "flag", "nation", "country", "banner", "uzbekistan"],
                  "emoji": "🇺🇿"
                },
                {
                  "keywords": ["vu", "flag", "nation", "country", "banner", "vanuatu"],
                  "emoji": "🇻🇺"
                },
                {
                  "keywords": ["vatican", "city", "flag", "nation", "country", "banner", "vatican", "city"],
                  "emoji": "🇻🇦"
                },
                {
                  "keywords": ["ve", "bolivarian", "republic", "flag", "nation", "country", "banner", "venezuela"],
                  "emoji": "🇻🇪"
                },
                {
                  "keywords": ["viet", "nam", "flag", "nation", "country", "banner", "vietnam"],
                  "emoji": "🇻🇳"
                },
                {
                  "keywords": ["wallis", "futuna", "flag", "nation", "country", "banner", "wallis", "futuna"],
                  "emoji": "🇼🇫"
                },
                {
                  "keywords": ["western", "sahara", "flag", "nation", "country", "banner", "western", "sahara"],
                  "emoji": "🇪🇭"
                },
                {
                  "keywords": ["ye", "flag", "nation", "country", "banner", "yemen"],
                  "emoji": "🇾🇪"
                },
                {
                  "keywords": ["zm", "flag", "nation", "country", "banner", "zambia"],
                  "emoji": "🇿🇲"
                },
                {
                  "keywords": ["zw", "flag", "nation", "zimbabwe", "banner", "country"],
                  "emoji": "🇿🇼"
                },
                {
                  "keywords": ["un", "flag", "banner", "united", "nations"],
                  "emoji": "🇺🇳"
                },
                {
                  "keywords": ["skull", "crossbones", "flag", "banner", "pirate"],
                  "emoji": "🏴‍☠️"
              }
                   ]
            }
          
    ]
    }
    """.utf8)
    
    static func getEmojis(completion: @escaping ((Data) -> Void)) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
            completion(self.json)
        }
    }
}

