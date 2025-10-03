import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/shared/components/ui/card';

export const View3 = () => {
  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-6">View 3</h1>
      <Card>
        <CardHeader>
          <CardTitle>View 3 Content</CardTitle>
          <CardDescription>This is a placeholder for View 3</CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-gray-600">Content for View 3 will be displayed here.</p>
        </CardContent>
      </Card>
    </div>
  );
};
