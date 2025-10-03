import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/shared/components/ui/card';

export const View1 = () => {
  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-6">View 1</h1>
      <Card>
        <CardHeader>
          <CardTitle>View 1 Content</CardTitle>
          <CardDescription>This is a placeholder for View 1</CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-gray-600">Content for View 1 will be displayed here.</p>
        </CardContent>
      </Card>
    </div>
  );
};
