import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/shared/components/ui/card';
import { useAuth } from '@/shared/hooks/useAuth';
import { api } from '@/shared/utils/api';
import { CheckCircle2, XCircle } from 'lucide-react';
import { useEffect, useState } from 'react';

interface DbHealth {
  connected: boolean;
  message: string;
}

export const WelcomePage = () => {
  const { user } = useAuth();
  const [dbHealth, setDbHealth] = useState<DbHealth | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const checkDbHealth = async () => {
      try {
        const response = await api.get<DbHealth>('/api/v1/health/db');
        setDbHealth(response.data);
      } catch (error) {
        setDbHealth({ connected: false, message: 'Failed to check database connection' });
      } finally {
        setLoading(false);
      }
    };

    checkDbHealth();
  }, []);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Welcome, {user?.name}!</h1>
        <p className="text-gray-600 mt-2">Here's your application dashboard</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Database Connection Status</CardTitle>
          <CardDescription>Current status of the PostgreSQL database connection</CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? (
            <p className="text-gray-500">Checking connection...</p>
          ) : (
            <div className="flex items-center space-x-3">
              {dbHealth?.connected ? (
                <>
                  <CheckCircle2 className="w-6 h-6 text-green-500" />
                  <div>
                    <p className="font-semibold text-green-700">Connected</p>
                    <p className="text-sm text-gray-600">{dbHealth.message}</p>
                  </div>
                </>
              ) : (
                <>
                  <XCircle className="w-6 h-6 text-red-500" />
                  <div>
                    <p className="font-semibold text-red-700">Disconnected</p>
                    <p className="text-sm text-gray-600">{dbHealth?.message}</p>
                  </div>
                </>
              )}
            </div>
          )}
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Quick Stats</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">0</p>
            <p className="text-sm text-gray-600">Total Items</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Activity</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">0</p>
            <p className="text-sm text-gray-600">Recent Actions</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Status</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold text-green-600">Active</p>
            <p className="text-sm text-gray-600">System Status</p>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};
