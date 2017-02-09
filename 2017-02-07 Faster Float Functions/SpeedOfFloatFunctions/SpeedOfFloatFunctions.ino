
#include <arm_math.h>

#include "db.c"

const int N_samps = 1000;
const int max_N_funcs = 30;
float vals[N_samps], vals_out[N_samps][max_N_funcs];
float min_val_dB = 140.0f, max_val_dB = 0.0f;


//https://community.arm.com/tools/f/discussions/4292/cmsis-dsp-new-functionality-proposal/22621#22621
/* ----------------------------------------------------------------------
** Fast approximation to the log2() function.  It uses a two step
** process.  First, it decomposes the floating-point number into
** a fractional component F and an exponent E.  The fraction component
** is used in a polynomial approximation and then the exponent added
** to the result.  A 3rd order polynomial is used and the result
** when computing db20() is accurate to 7.984884e-003 dB.
** ------------------------------------------------------------------- */
float log2f_approx_coeff[4] = {1.23149591368684f, -4.11852516267426f, 6.02197014179219f, -3.13396450166353f};
float log2f_approx(float X) {
  float *C = &log2f_approx_coeff[0];
  float Y;
  float F;
  int E;

  // This is the approximation to log2()
  F = frexpf(fabsf(X), &E);
  //  Y = C[0]*F*F*F + C[1]*F*F + C[2]*F + C[3] + E;
  Y = *C++;
  Y *= F;
  Y += (*C++);
  Y *= F;
  Y += (*C++);
  Y *= F;
  Y += (*C++);
  Y += E;

  return(Y);
}

void setup() {
  Serial.begin(1152000);
  delay(500);
  Serial.println("Floating point function testing...");

  //prepare samples
  float val_dB;
  for (int i=0; i < N_samps; i++) {
    val_dB = (max_val_dB - min_val_dB)/(N_samps-1)*i + min_val_dB;
    vals[i] = sqrtf(powf(10.0,val_dB/10.f));
  }
}

void loop() {
  // put your main code here, to run repeatedly:
  uint32_t total_cycles[max_N_funcs];
  int N_funcs;
  char names[40][max_N_funcs];
  for (int i=0; i < max_N_funcs; i++) total_cycles[i]=0;
  uint32_t foo_cycles;
  float foo_in, foo_out;
  const float const_log_10 = logf(10.0);

  //copy from Teensy cores/teensy3/AudioStream.cpp/update_all  https://github.com/PaulStoffregen/cores/blob/master/teensy3/AudioStream.cpp
  ARM_DEMCR |= ARM_DEMCR_TRCENA;
  ARM_DWT_CTRL |= ARM_DWT_CTRL_CYCCNTENA;

  for (int i=0; i < N_samps; i++) {
    int ind = 0;

    //prime the pump
    foo_in = fabs(vals[i]);
    float foo_in2 = (float)i;
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = foo_in + foo_in2;
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    //foo_out = logf(foo_in);
    //vals_out[i][ind+1] = foo_out;
    //foo_out = expf(foo_out);
    //vals_out[i][ind+2] = foo_out;
    //total_cycles[ind] += foo_cycles; 
    //ind++;

    // add, sub, mult, divide
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = foo_in + foo_in2;
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles; 
    strcpy(names[ind],"Add");
    ind++;  

    foo_in = foo_out;
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = foo_in - foo_in2;
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles; 
    strcpy(names[ind],"Subtract");
    ind++; 

    foo_in = fabs(vals[i]);
    //float foo_in2 = (float)(i);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = foo_in * foo_in2;
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles; 
    strcpy(names[ind],"Multiply");
    ind++;

    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = foo_in / foo_in2;
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles; 
    strcpy(names[ind],"Divide");
    ind++;
    
    // //////////////////////////// Implicitly float

    //do sqrt
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = sqrt(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles; 
    strcpy(names[ind],"sqrt(x)");
    ind++; 

    //do log
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = log(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles; 
    strcpy(names[ind],"log(x)");
    ind++;  
    
    //do expf
    foo_in = foo_out;
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = exp(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"exp(x)");
    ind++;
    
    //do log10
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = log10(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"log10(x)");
    ind++;

    //do powf
    foo_in = foo_out;
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = pow(10.0f,foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"pow(10.0f,x)");
    ind++;

    // //////////////////////////////////////// explicitly float versions

//    //do powf(10,x) via exp(log(10)*x)
//    foo_in = log10f(fabs(vals[i])); //go back to output of log10
//    foo_cycles = ARM_DWT_CYCCNT;
//    foo_out = expf(const_log_10*foo_in);
//    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
//    vals_out[i][ind] = foo_out;
//    total_cycles[ind] += foo_cycles;
//    strcpy(names[ind],"expf(log(10.0f)*x)");
//    ind++;

    //do sqrt
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = sqrtf(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles; 
    strcpy(names[ind],"sqrtf(x)");
    ind++; 

     //do log
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = logf(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles; 
    strcpy(names[ind],"logf(x)");
    ind++;  
    
    //do expf
    foo_in = foo_out;
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = expf(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"expf(x)");
    ind++;
    
    //do log10
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = log10f(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"log10f(x)");
    ind++;

    //do log10 approximation
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = log2f_approx(foo_in)*0.3010299956639812f;
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"log2(x)/log2(10)");
    ind++;
    
    
    //do powf(10,x)
    foo_in = foo_out;
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = powf(10.0f,foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"powf(10.0f,x)");
    ind++;

    //do powf(10,x) via exp(log(10)*x)
    foo_in = vals_out[i][ind-2]; //go back to output of log10
    //foo_in = foo_out;
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = expf(const_log_10*foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"expf(log(10.0f)*x)");
    ind++;


    //steve's approximation...log10
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = cha_db2(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    foo_out = foo_out / 20.0f; //to get consistent with the other functinos
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"cha_db2(x)");
    ind++;

    //steve's approximation...pow10
    foo_in = foo_out*20.0f;
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = cha_undb2(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"cha_undb2(x)");
    ind++;    


     // //////////////////////////////////////// explicitly float versions AGAIN

//    //do arm sqrt
//    foo_in = fabs(vals[i]);
//    foo_cycles = ARM_DWT_CYCCNT;
//    //foo_out = sqrtf(foo_in);
//    arm_sqrt_f32(foo_in, &foo_out);
//    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
//    vals_out[i][ind] = foo_out;
//    total_cycles[ind] += foo_cycles; 
//    strcpy(names[ind],"arm_sqrt_f32(x)");
//    ind++;     

    //do sqrt
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = sqrtf(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles; 
    strcpy(names[ind],"sqrtf(x)");
    ind++; 

    //do log
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = logf(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles; 
    strcpy(names[ind],"logf(x)");
    ind++;  
    
    //do expf
    foo_in = foo_out;
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = expf(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"expf(x)");
    ind++;
    
    //do log10
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = log10f(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"log10f(x)");
    ind++;

    //do chip's approximation to log10
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = log2f_approx(foo_in)*0.3010299956639812f;
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"log2(x)/log2(10)");
    ind++;

    //do powf(10,x)
    foo_in = foo_out;
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = powf(10.0f,foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"powf(10.0f,x)");
    ind++;

    //do powf(10,x) via exp(log(10)*x)
    foo_in = vals_out[i][ind-2]; //go back to output of log10
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = expf(const_log_10*foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"expf(log(10.0f)*x)");
    ind++;

   //steve's approximation...log10
    foo_in = fabs(vals[i]);
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = cha_db2(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    foo_out = foo_out / 20.0f; //to get consistent with the other functinos
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"cha_db2(x)");
    ind++;

    //steve's approximation...pow10
    foo_in = foo_out*20.0f;
    foo_cycles = ARM_DWT_CYCCNT;
    foo_out = cha_undb2(foo_in);
    foo_cycles = (ARM_DWT_CYCCNT - foo_cycles);
    vals_out[i][ind] = foo_out;
    total_cycles[ind] += foo_cycles;
    strcpy(names[ind],"cha_undb2(x)");
    ind++;    

    //this counts how many functions were actually used
    N_funcs = ind;
  }


//  //print output
//  for (int i=0; i < N_samps; i++) {
//    Serial.print(i); Serial.print(": in = ");
//    Serial.print(vals[i]); Serial.print(", out = ");
//    for (int j=0; j < N_funcs; j++) {
//      Serial.print(vals_out[i][j]); Serial.print(", "); 
//    }
//    Serial.println();
//  }

  for (int i =0; i<N_samps; i++) {
    int ind1 = 14-1; int ind2 = 13-1;
    Serial.print(i);
    Serial.print(": true = "); Serial.print(vals_out[i][ind2]);
    Serial.print(", approx = "); Serial.print(vals_out[i][ind1]);
    Serial.print(", error % = "); Serial.print((vals_out[i][ind1]-vals_out[i][ind2])/vals_out[i][ind2]*100.f);
    Serial.println();
  }

  for (int j = 0; j < N_funcs; j++) {
    Serial.print("Timing for "); Serial.print(names[j]);
    Serial.print(": ");
    Serial.print(((float)total_cycles[j])/((float)N_samps));
    Serial.print(" cycles");
    Serial.println();
  }

  delay(6000);
  
}
