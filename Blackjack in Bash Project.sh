####################################################################
############    blackjack.exe      #################################
####################################################################
#
####################################################################
# Author: Ed Emerling                                              #
# Program: This script is a modified game of Blackjack.            #
# Logic: Player starts the program and places a bet.               #
# Cards are dealt and totaled. Player chooses to hit or stand.     #
# Dealer hits on 16 or less. Cards are totaled and winner is set.  #
# Pleaer chooses to continue or not.                               #
####################################################################
#
#
#####     Variable Definitions     #################################
####################################################################
# $bankroll = How much cash the player has.                        #
# $hit = toggle if player hits or stands.                          #
# $play = toggle variable to exit/continue the game loop.          #
# $deal = how many times to run the loop that deals the cards.     #
# $hands = number of hands played.                                 #
# $owner = toggles a card ownership to dealer or player.           #
# $turn = toggles the player turn                                  #
# $DealerValue = The total value of the dealer's cards             #
# $wager = How much the player is betting on a hand.               #
# $PlayerValue = The total value of the player's cards             #
####################################################################
#
######     Explanation of child scripts and source files     #####################
##################################################################################
# deal.exe Deals the cards at the start of the hand and for hits.                #
# total.exe Tallies cards and bets when a win occurs for either player or dealer #
# deck.txt Contains the deck of cards                                            #
# PlayerHand.txt Cards in the player's hand                                      #
# DealerHand.txt Cards in the dealer's hand                                      #
##################################################################################
#
#####     This section initializes the program.     ##############################
#
#
#####   *** declare integer variable types and set pre-game value ***
set +o noclobber
chmod a+rwx deal.exe
chmod a+rwx total.exe
chmod a+rwx blackjack.exe
declare -i bankroll
declare -i deal
declare -i DealerValue
declare -i hands
declare -i PlayerValue
declare -i wager
export bankroll=10000
hands=0
#####   *** clear the screen and prompt user to begin play ***
clear
echo "Welcome to Bashjack!"
echo "Today is $(date)."
echo "Would you like to play a game?"
read play
while [ "$play" == "y" ]; do
#
#####     This section resets the control structures for the hand     #########
###############################################################################
#####   *** set beginning values for variables and make global if needed ***
export deal=4
export DealerValue=0
export hit="start"
export owner="player"
export PlayerValue=0
#####   *** clear player and dealer hands ***
if [ "$hands" != "0" ]
        then
        rm PlayerHand.txt DealerHand.txt
fi
#####     This section controls the betting     ###############################
###############################################################################
#####   *** prompt user to make wager ***
echo "You have " $bankroll " dollars in your account."
echo "How much would you like to bet on this hand? "
read wager
#####   *** deduct wager from bankroll ***
bankroll=$bankroll-$wager
echo You bet \$$wager and have \$$bankroll remaining.
sleep 3; clear
#
#####      This starts the control structure for all gameplay     #############
###############################################################################
source ./deal.exe
#####   *** total cards and display score ***
##### Ref: http://www.liamdelahunty.com/tips/linux_ls_awk_totals.php
##### Ref: https://www.tutorialspoint.com/awk/awk_assignment_operators.htm
##### Ref: https://unix.stackexchange.com/questions/242946/
alias DealerValue="awk -F':' '{ DealerValue += \$3} END { print DealerValue }' DealerHand.txt"
alias PlayerValue="awk -F':' '{ PlayerValue += \$3} END { print PlayerValue }' PlayerHand.txt"
echo "You have $(PlayerValue) and the Dealer has $(DealerValue)."
PV=`PlayerValue`
DV=`DealerValue`
#####   *** evaluate if a Blackjack was dealt ***
if [ "$DV" -eq "21" ] || [ "$PV" -eq "21" ]
        then
                source ./total.exe
                hit="s"
fi
#####   *** conduct the player's turn ***
while [ "$hit" != "s" ]; do
echo "(H)it or (S)tand? "
read hit
sleep 1; clear
case $hit in
        "h") deal=1
                 source ./deal.exe
                 echo "You have $(PlayerValue) and the Dealer has $(DealerValue)."
                 PV=`PlayerValue`
                 if [ "$PV" -gt "21" ]
                        then
                        hit="s"
                 fi
                 ;;
        "s") echo "You have $(PlayerValue) and the Dealer has $(DealerValue)."
                 ;;
        *)       echo "Please select 'h' or 's.'"
                 ;;
esac
done
#####   *** conduct the dealer's turn ***
while [ "$DV" -lt "17" ] && [ "$PV" -lt "22" ]; do
        clear; deal=1; hit="h"; owner="dealer"; source ./deal.exe; sleep 4
        DV=`DealerValue`
#done
done
source ./total.exe
##############################################################################
hands=$hands+1
echo You played $hands hands and have \$$bankroll dollars!
if [ "$bankroll" -lt "1" ]
        then
        play="n"
        else
        echo "Would you like to play again?"
        read play
        sleep 1; clear
fi
done
sleep 2; echo "Goodbye!"; clear
rm PlayerHand.txt DealerHand.txt
unset deal; unset DealerValue; unset hit; unset owner; unset PlayerValue; set -o noclobber
unset wager; unset owner; unset bankroll
#
#
#
#############################################################################################
####################  deal.exe        #######################################################
#############################################################################################
#
#
while [ "$deal" -gt "0" ]; do
#####   *** generate a random card number (ref: Stack Overflow) ***
card=$((1 + RANDOM % 52))
#####   *** get card from deck; -n suppresses pattern space; ***
#####   *** p prints current space (ref: Stack Overflow)     ***
content=`sed -n "$card p" deck.txt`
#####   *** decide who gets the card ***
if [ "$owner" == "player" ]
        then
        echo $content >> PlayerHand.txt
        else
        echo $content >> DealerHand.txt
fi
#####   *** decrease number of cards left to be dealt ***
let deal=$deal-1
#####   *** switch who the next card is dealt to if necessary ***
#####   *** THIS IS A VERY COMMON STRUCTURE FOR TOGGLING ***
if [ "$hit" == "start" ]
        then
        if [ "$owner" == "player" ]
                then
                owner="dealer"
                else
                owner="player"
        fi
fi
done
echo "Your cards are:"
echo " "
awk -F':' '{print $2}' PlayerHand.txt
echo " "
echo "The Dealer's cards are:"
echo " "
awk -F':' '{print $2}'  DealerHand.txt
echo " "
#
#
#
##############################################################################
#############       total.exe       ##########################################
##############################################################################
#
#
alias DealerValue="awk -F':' '{ DealerValue += \$3} END { print DealerValue }' DealerHand.txt"
alias PlayerValue="awk -F':' '{ PlayerValue += \$3} END { print PlayerValue }' PlayerHand.txt"
echo "You have $(PlayerValue) and the Dealer has $(DealerValue)."
PV=`PlayerValue`
DV=`DealerValue`
if [ "$DV" -lt "$PV" ] && [ "$PV" -lt "22" ] || [ "$DV" -gt "21" ]
        then
                echo "You win!"
                bankroll=$bankroll+$wager*2
        else
       echo "You lose."
fi
#
#
#
####################################################################################
###############     deck.txt     ###################################################
####################################################################################
#
1:Ace of Spades:11:y
2:King of Spades:10:n
3:Queen of Spades:10:n
4:Jack of Spades:10:n
5:10 of Spades:10:n
6:9 of Spades:9:n
7:8 of Spades:8:n
8:7 of Spades:7:n
9:6 of Spades:6:n
10:5 of Spades:5:n
11:4 of Spades:4:n
12:3 of Spades:3:n
13:2 of Spades:2:n
14:Ace of Hearts:11:y
15:King of Hearts:10:n
16:Queen of Hearts:10:n
17:Jack of Hearts:10:n
18:10 of Hearts:10:n
19:9 of Hearts:9:n
20:8 of Hearts:8:n
21:7 of Hearts:7:n
22:6 of Hearts:6:n
23:5 of Hearts:5:n
24:4 of Hearts:4:n
25:3 of Hearts:3:n
26:2 of Hearts:2:n
27:Ace of Clubs:11:y
28:King of Clubs:10:n
29:Queen of Clubs:10:n
30:Jack of Clubs:10:n
31:10 of Clubs:10:n
32:9 of Clubs:9:n
33:8 of Clubs:8:n
34:7 of Clubs:7:n
35:6 of Clubs:6:n
36:5 of Clubs:5:n
37:4 of Clubs:4:n
38:3 of Clubs:3:n
39:2 of Clubs:2:n
40:Ace of Diamonds:11:y
41:King of Diamonds:10:n
42:Queen of Diamonds:10:n
43:Jack of Diamonds:10:n
44:10 of Diamonds:10:n
45:9 of Diamonds:9:n
46:8 of Diamonds:8:n
47:7 of Diamonds:7:n
48:6 of Diamonds:6:n
49:5 of Diamonds:5:n
50:4 of Diamonds:4:n
51:3 of Diamonds:3:n
52:2 of Diamonds:2:n

