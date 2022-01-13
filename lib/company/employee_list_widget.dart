import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smallbusiness/auth/app_context.dart';
import 'package:smallbusiness/company/employee_list_cubit.dart';
import 'package:provider/provider.dart';
import 'package:smallbusiness/company/models.dart';
import 'package:smallbusiness/reusable/loader.dart';

class EmployeeListWidget extends StatelessWidget {
  const EmployeeListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mitarbeiterliste"),
      ),
      body: BlocProvider(
        create: (context) =>
            EmployeeListCubit(Provider.of<SbmContext>(context, listen: false)),
        child: BlocBuilder<EmployeeListCubit, EmployeeListState>(
          builder: (context, state) {
            return state is EmployeeListInitialized
                ? ListView.builder(
                    itemCount: state.employees.length,
                    itemBuilder: (context, index) {
                      Employee employee = state.employees[index];
                      return ListTile(
                        title: Text(
                            "${employee.person.firstName} ${employee.person.lastName} (${employee.employeeNo})"),
                        onTap: () async {
                          await Routemaster.of(context)
                              .push(
                                  "/employeeList/employeeMenu?employeeId=${employee.employeeRef!.id}")
                              .result;
                          context.read<EmployeeListCubit>().refresh();
                        },
                      );
                    })
                : LoadingAnimationScreen();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.person_add),
          onPressed: () {
            Routemaster.of(context).push("/employeeList/employeeEdit");
          },
          label: Text("Neuer Mitarbeiter")),
    );
  }
}
