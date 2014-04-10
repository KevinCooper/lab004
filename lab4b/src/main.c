#include <xuartlite_l.h>
#include <xparameters.h>
#include <string.h>

void getChar(unsigned char *inputPtr);
void putChar(unsigned char input);
void doleds(unsigned char *inputPtr);
void doswt(unsigned char *inputPtr);
void domon(unsigned char *inputPtr);
void donewline();
int main(void)
{
	unsigned char leds[]	= "led\0";
	unsigned char swt[]		= "swt\0";
	unsigned char mon[] 	= "mon\0";
	int output;
	unsigned char space[] 	= " ";

 while (1)
 {
  unsigned char input[] = "    \0";
  unsigned char *inputPtr = input;

  getChar(inputPtr);
  getChar(inputPtr+1);
  getChar(inputPtr+2);
  putChar(*space);
  if (*(inputPtr)==leds[0]&&*(inputPtr+1)==leds[1]&&*(inputPtr+2)==leds[2])	  doleds(inputPtr);
  if (*(inputPtr)==swt[0]&&*(inputPtr+1)==swt[1]&&*(inputPtr+2)==swt[2])	  doswt(inputPtr);
  if (*(inputPtr)==mon[0]&&*(inputPtr+1)==mon[1]&&*(inputPtr+2)==mon[2])	  domon(inputPtr);
  donewlines();
 }
 return 0;
}

void donewlines(){
	  unsigned char newline[] = "\x0A\x0D";
	  putChar(*newline);
	  putChar(*(newline+1));
}

void getChar(unsigned char *inputPtr){
	*inputPtr = XUartLite_RecvByte(0x84000000);
	XUartLite_SendByte(0x84000000, (unsigned char) *(inputPtr));
}
void putChar(unsigned char input){
	XUartLite_SendByte(0x84000000, input);
}
void doleds(unsigned char *inputPtr){
	XUartLite_SendByte(0x84000000, (unsigned char) *(inputPtr));
}
void doswt(unsigned char *inputPtr){
	XUartLite_SendByte(0x84000000, (unsigned char) *(inputPtr));
}
void domon(unsigned char *inputPtr){
	XUartLite_SendByte(0x84000000, (unsigned char) *(inputPtr));
}


