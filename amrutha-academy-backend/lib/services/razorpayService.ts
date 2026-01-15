import Razorpay from 'razorpay';
import crypto from 'crypto';

if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
  console.warn('Razorpay credentials not found in environment variables');
}

export const razorpayInstance = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID || '',
  key_secret: process.env.RAZORPAY_KEY_SECRET || '',
});

export class RazorpayService {
  static async createOrder(amount: number, currency: string = 'INR', receipt?: string, notes?: Record<string, string>) {
    try {
      const options = {
        amount: amount * 100, // Convert to paise (smallest currency unit)
        currency,
        receipt: receipt || `receipt_${Date.now()}`,
        notes: notes || {},
      };

      const order = await razorpayInstance.orders.create(options);
      
      return {
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
        keyId: process.env.RAZORPAY_KEY_ID,
      };
    } catch (error: any) {
      console.error('Razorpay order creation error:', error);
      throw new Error(error.error?.description || 'Failed to create Razorpay order');
    }
  }

  static verifyPayment(orderId: string, paymentId: string, signature: string): boolean {
    try {
      const text = `${orderId}|${paymentId}`;
      const generatedSignature = crypto
        .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET || '')
        .update(text)
        .digest('hex');

      return generatedSignature === signature;
    } catch (error) {
      console.error('Razorpay signature verification error:', error);
      return false;
    }
  }

  static async getPaymentDetails(paymentId: string) {
    try {
      const payment = await razorpayInstance.payments.fetch(paymentId);
      return payment;
    } catch (error: any) {
      console.error('Razorpay fetch payment error:', error);
      throw new Error(error.error?.description || 'Failed to fetch payment details');
    }
  }
}




