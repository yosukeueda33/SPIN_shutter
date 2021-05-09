// Common
mtype = {NO_REQ};

// DOOR
mtype = {DOOR_OPENED, DOOR_CLOSED};

mtype door_front_state = DOOR_OPENED;
mtype door_back_state = DOOR_CLOSED;

// DOOR Lock
mtype = {DOOR_LOCKED, DOOR_UNLOCKED};
mtype = {DOOR_LOCK_REQ, DOOR_UNLOCK_REQ};
mtype door_lock_front_state = DOOR_UNLOCKED; 
mtype door_lock_back_state = DOOR_UNLOCKED; 
mtype door_lock_front_req = NO_REQ; 
mtype door_lock_back_req = NO_REQ; 

// SHUTTER
mtype = {SHUTTER_UPPED, SHUTTER_DOWNED}
mtype = {SHUTTER_UP_REQ, SHUTTER_DOWN_REQ};

mtype shutter_state = SHUTTER_UPPED;
mtype shutter_req = NO_REQ;

// Electrick-Shock
mtype = {ES_ON_REQ, ES_OFF_REQ};
mtype = {ES_ON, ES_OFF};
mtype es_state = ES_OFF;
mtype es_req = NO_REQ;

active proctype User()
{
    printf("User started.\n")
    do
    ::  printf("select door action\n");
        if
        :: door_lock_front_state == DOOR_UNLOCKED ->
            if
            :: door_front_state = DOOR_OPENED;
                printf("door front opened\n");
            :: door_front_state = DOOR_CLOSED;
                printf("door front closed\n");
            :: else
            fi;
        :: door_lock_back_state == DOOR_UNLOCKED ->
            if
            :: door_back_state = DOOR_OPENED;
                printf("door back opened\n");
            :: door_back_state = DOOR_CLOSED;
                printf("door back closed\n");
            :: else
            fi;
        :: else
        fi;
        printf("select action\n");
        if 
        :: door_lock_front_req = DOOR_LOCK_REQ; 
        :: door_lock_front_req = DOOR_UNLOCK_REQ; 
        :: door_lock_back_req = DOOR_LOCK_REQ; 
        :: door_lock_back_req = DOOR_UNLOCK_REQ; 
        :: shutter_req = SHUTTER_UP_REQ;
        :: shutter_req = SHUTTER_DOWN_REQ;
        :: es_req = ES_ON_REQ; 
        :: es_req = ES_OFF_REQ; 
        :: else 
        fi;
        printf("down reqs\n");
        door_lock_front_req = NO_REQ;
        door_lock_back_req = NO_REQ;
        shutter_req = NO_REQ;
        es_req = NO_REQ;
    od;
}


// Not needed.
// active proctype KeyController()
// {
// }

active proctype DoorController()
{
    do
    ::  if 
        :: atomic{
                door_front_state == DOOR_CLOSED->
                if
                :: atomic{
                        door_lock_front_req == DOOR_LOCK_REQ ->
                        door_lock_front_state = DOOR_LOCKED;
                        printf("front door locked\n");
                    }
                :: atomic{
                        (door_lock_front_req == DOOR_UNLOCK_REQ) ->
                            door_lock_front_state = DOOR_UNLOCKED;
                            printf("front door unlocked\n");
                            printf("es_state:");
                            printm(es_state)
                            printf("\n")
                    }
                :: else
                fi;
            }
        :: else
        fi;
        if 
        :: atomic{
                door_back_state == DOOR_CLOSED->
                if
                :: atomic{
                        door_lock_back_req == DOOR_LOCK_REQ ->
                        door_lock_back_state = DOOR_LOCKED;
                        printf("back door locked\n");
                    }
                :: atomic{
                        (door_lock_back_req == DOOR_UNLOCK_REQ) ->
                            door_lock_back_state = DOOR_UNLOCKED;
                            printf("back door unlocked\n");
                            printf("es_state:");
                            printm(es_state)
                            printf("\n")
                    }
                :: else
                fi;
            }
        :: else
        fi;
    od
}

active proctype ShutterController()
{
    do
    :: atomic{
            shutter_req == SHUTTER_UP_REQ ->
            shutter_state = SHUTTER_UPPED;
            printf("shutter upped\n");
        }
    :: atomic{
            shutter_req == SHUTTER_DOWN_REQ ->
            shutter_state = SHUTTER_DOWNED;
            printf("shutter downed\n");
        }
    :: atomic{
            (es_req == ES_ON_REQ) && (shutter_state == SHUTTER_DOWNED) &&
            (door_front_state == DOOR_CLOSED) && (door_lock_front_state == DOOR_LOCKED) &&
            (door_back_state == DOOR_CLOSED) && (door_lock_back_state == DOOR_LOCKED) ->
                es_state = ES_ON;
                printf("electronic shock ON!!!!!!!!!!!!!!\n");
                printf("door_lock_front_state:");
                printm(door_lock_front_state);
                printf("\n");
                printf("door_lock_back_state:");
                printm(door_lock_back_state);
                printf("\n");
        }
    :: atomic{
            es_req == ES_OFF_REQ ->
            es_state = ES_OFF;
            printf("electronic shock OFF\n");
        }
    :: else;
    od;
}


#define C_ES_ON (es_state == ES_ON)
#define C_ANY_UNLOCKED ((door_lock_front_state == DOOR_UNLOCKED) ||\
    (door_lock_back_state == DOOR_UNLOCKED))
#define C_SHUTTER_UPPED (shutter_state == SHUTTER_UPPED)

// For inner person safety.
ltl w1{always !((C_ES_ON) && (C_ANY_UNLOCKED))}

// For energy saving. 
ltl w2{always !((C_ES_ON) && (C_SHUTTER_UPPED))}
