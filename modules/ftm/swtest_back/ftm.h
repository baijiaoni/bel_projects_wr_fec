#ifndef _FTM_H_
#define _FTM_H_



//masks & constants
#define MSK_PAGE              (1<<0)

#define NORMAL                0
#define OFFSET                1
#define NOW                   2


#define CMD_RST           		(1<<0)	//Reset FTM status and counters
#define CMD_PAGESWAP      		(1<<1)	//Use mempage A/B
#define CMD_PAGESWAP_I   		(1<<2)	//Use mempage A/B immediately
#define CMD_RUN    		      (1<<3)	//Use mempage A/B immediately
#define CMD_RUN_NOW 		      (1<<4)	//Use mempage A/B immediately
#define CMD_STOP    		      (1<<5)	//Use mempage A/B immediately
#define CMD_STOP_NOW 	      (1<<6)	//Use mempage A/B immediately

#define CMD_DBG_0             (1<<8)
#define CMD_DBG_1             (1<<9)

#define FTM_RUNNING           (1<<0)

#define CYC_START_ABS_MSK     (1<<8)	   //Start timing cycle at time specified
#define CYC_START_REL_MSK     (1<<8)	   //Start timing cycle at now + time specifed
#define CYC_DBG           (1<<10)	   //Run Cycle in  debug mode (start time will be corrected if in the past, no error detection)
#define CYC_SEL           0xffff0000	//cycle select




#define CYC_WAITING      (1<<0)	//shows if cycle is waiting for condition
#define CYC_DBG          (1<<1)	//shows cycle debug mode is active/inactive
#define CYC_ACTIVE       (1<<2)	//shows cycle is active/inactive
#define CYC_ERROR      	 (1<<3)	//error occured during cycle execution




#define TIMER_CYC_START       8
#define TIMER_CYC_PREP        TIMER_CYC_START+1 
#define TIMER_MSG_PREP        TIMER_CYC_PREP+1  
#define TIMER_ABS       CYC_ABS_TIME
#define TIMER_PER        (1<<2) 


#define TIMER_CYC_START_MSK   (1<<TIMER_CYC_START)
#define TIMER_CYC_PREP_MSK    (1<<TIMER_CYC_PREP) 
#define TIMER_MSG_PREP_MSK    (1<<TIMER_MSG_PREP)

#define TIMER_CFG_SUCCESS     0
#define TIMER_CFG_ERROR_0     -1
#define TIMER_CFG_ERROR_1     -2

// Priority Queue RegisterLayout
static const struct {
   unsigned int rst;
   unsigned int force;
   unsigned int dbgSet;
   unsigned int dbgGet;
   unsigned int clear;
   unsigned int cfgGet;
   unsigned int cfgSet;
   unsigned int cfgClr;
   unsigned int dstAdr;
   unsigned int heapCnt;
   unsigned int msgCntO;
   unsigned int msgCntI;
   unsigned int tTrnHi;
   unsigned int tTrnLo;
   unsigned int tDueHi;
   unsigned int tDueLo;
   unsigned int msgMin;
   unsigned int msgMax;
   unsigned int ebmAdr;
   unsigned int cfg_ENA;
   unsigned int cfg_FIFO;    
   unsigned int cfg_IRQ;
   unsigned int cfg_AUTOPOP;
   unsigned int cfg_AUTOFLUSH_TIME;
   unsigned int cfg_AUTOFLUSH_MSGS;
   unsigned int force_POP;
   unsigned int force_FLUSH;
} r_FPQ = {    .rst     =  0x00 >> 2,
               .dbgSet  =  0x04 >> 2,
               .dbgGet  =  0x08 >> 2,
               .clear   =  0x0C >> 2,
               .cfgGet  =  0x10 >> 2,
               .cfgSet  =  0x14 >> 2,
               .cfgClr  =  0x18 >> 2,
               .dstAdr  =  0x1C >> 2,
               .heapCnt =  0x20 >> 2,
               .msgCntO =  0x24 >> 2,
               .msgCntI =  0x28 >> 2,
               .tTrnHi  =  0x2C >> 2,
               .tTrnLo  =  0x30 >> 2,
               .tDueHi  =  0x34 >> 2,
               .tDueLo  =  0x38 >> 2,
               .msgMin  =  0x3C >> 2,
               .msgMax  =  0x40 >> 2,
               .ebmAdr  =  0x44 >> 2,
               .cfg_ENA             = 1<<0,
               .cfg_FIFO            = 1<<1,    
               .cfg_IRQ             = 1<<2,
               .cfg_AUTOPOP         = 1<<3,
               .cfg_AUTOFLUSH_TIME  = 1<<4,
               .cfg_AUTOFLUSH_MSGS  = 1<<5,
               .force_POP           = 1<<0,
               .force_FLUSH         = 1<<1
};



typedef unsigned int t_status;

//control & status registers

typedef struct {
   unsigned int hi;
   unsigned int lo;
} t_dw;



typedef union {
   unsigned long long   v64;
   t_dw                 v32;               
} u_dword;

typedef u_dword t_time ;

typedef struct {
   u_dword id;
   u_dword par;
   unsigned int res;
   unsigned int tef;
   u_dword ts;
   u_dword offs;
} t_ftmMsg;

typedef struct {
   unsigned int       status;   
   t_time tTrn;
   t_time tMargin;
   t_time tStart;
   t_time tPeriod;
   t_time tExec;
   int                rep;
   int                repCnt;
   int                msgCnt;
   
   unsigned int       qtyMsgs;
   unsigned int       procMsg;  
   t_ftmMsg           msgs[10];
   
} t_ftmCycle;

typedef struct {
   unsigned int   msgChStat;
   unsigned int   cycleSel;
   t_ftmCycle     cycles[2];
   
} t_fesaPage;

typedef struct {
   unsigned int cmd;
   unsigned int status;
   unsigned int pageSel; 
   t_fesaPage page[2];
} t_fesaFtmIf;

extern const t_time tProc;

extern unsigned int* _startshared[];
extern unsigned int* _endshared[];


volatile t_fesaPage* pPageAct;
volatile t_fesaPage* pPageInAct;
extern volatile t_fesaFtmIf* pFesaFtmIf;
volatile unsigned int swap;
volatile unsigned int msgProcPending;

inline void updateCycExecTime(t_ftmCycle* c);
inline void updatePageExecTimes(t_fesaPage* pPage);
inline void updateAllExecTimes();

unsigned int setMsgTimer(t_time tDeadline, unsigned int msg, unsigned int timerIdx);
unsigned int setCycleTimer(t_ftmCycle* cyc, unsigned int mode);


void processDueMsgs();
void ISR_timer();

void ftmInit(void);
void fesaInit(void);

void fesaCmdEval();

void ISR_timer();

t_ftmMsg* addFtmMsg(unsigned int eca_adr, t_ftmMsg* pMsg);

void sendFtmMsgPacket();

#endif
